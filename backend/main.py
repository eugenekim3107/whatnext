from fastapi import FastAPI, Security, HTTPException, Depends
from fastapi.security.api_key import APIKeyHeader
from starlette.status import HTTP_403_FORBIDDEN
from pymongo import MongoClient
import motor.motor_asyncio
from typing import List, Optional, Dict
from pydantic import BaseModel
from datetime import datetime, timedelta
import pytz
from openai import OpenAI
import requests
import redis
import json

##############################
### Setup and requirements ###
##############################

# API key credentials
API_KEY = "whatnext"
API_KEY_NAME = "whatnext_token"
api_key_header = APIKeyHeader(name=API_KEY_NAME, auto_error=False)

# MongoDB (make sure to change the ip address to match the ec2 instance ip address)
MONGO_DETAILS = "mongodb://eugenekim:whatnext@localhost:8000/"
mongo_client = motor.motor_asyncio.AsyncIOMotorClient(MONGO_DETAILS)
db = mongo_client["locationDatabase"]

# OpenAI
openai_client = OpenAI(api_key='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')

# Redis server for chat and user history
redis_client = redis.Redis(host='localhost', port=8001, db=0, decode_responses=True)

app = FastAPI()

##########################
### Location retrieval ###
##########################

class GeoJSON(BaseModel):
    type: str
    coordinates: List[float]

class Location(BaseModel):
    business_id: str
    name: Optional[str] = None
    address: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    postal_code: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    stars: Optional[float] = None
    review_count: Optional[int] = 0
    cur_open: Optional[int] = 0
    categories: Optional[str] = None
    tag: Optional[List[str]] = None
    hours: Optional[Dict[str, List[str]]] = None
    location: GeoJSON
    price: Optional[str] = None

# Verifies correct api key
async def get_api_key(api_key: str = Security(api_key_header)):
    if api_key == API_KEY:
        return api_key
    else:
        raise HTTPException(
            status_code=HTTP_403_FORBIDDEN, detail="Invalid API Key"
        )

# Checks if the businesses is currently open
def is_within_hours(now, hours):
    if not hours or not isinstance(hours, list) or len(hours) != 2:
        return False
    open_time_str, close_time_str = hours
    open_hour, open_minute = int(open_time_str[:2]), int(open_time_str[2:])
    close_hour, close_minute = int(close_time_str[:2]), int(close_time_str[2:])

    open_time = now.replace(hour=open_hour, minute=open_minute, second=0, microsecond=0)
    close_time = now.replace(hour=close_hour, minute=close_minute, second=0, microsecond=0)

    if close_time <= open_time:
        close_time += timedelta(days=1)

    return open_time <= now <= close_time


async def fetch_nearby_locations(latitude: float, 
                                 longitude: float, 
                                 limit: int, 
                                 radius: float, 
                                 categories: str, 
                                 cur_open: int, 
                                 sort_by: str) -> List[Location]:
    query = {
        "location": {
            "$nearSphere": {
                "$geometry": {
                    "type": "Point",
                    "coordinates": [longitude, latitude]
                },
                "$maxDistance": radius
            }
        },
        "is_open": 1,
    }

    if categories.lower() != "any":
        query["categories"] = {"$regex": categories, "$options": "i"} 

    now = datetime.now()

    try:
        items = await db.locations.find(query).sort(sort_by, -1).limit(limit).to_list(length=limit)
        open_businesses = []

        for item in items:
            item['cur_open'] = 0  # Default to not currently open
            day_of_week = now.strftime('%A')
            hours_list = item.get('hours', {}).get(day_of_week)

            if cur_open == 1 and is_within_hours(now, hours_list):
                item['cur_open'] = 1

            open_businesses.append(Location(**item))

        return open_businesses
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Retrieve nearby businesses based on location, time, category, and radius
@app.get("/nearby_locations", response_model=List[Location])
async def nearby_locations(latitude: float=32.8723812680163,
                           longitude: float=-117.21242234341588,
                           limit: int=20,
                           radius: float=10000.0,
                           categories: str="any", # 'any' is all categories
                           cur_open: int=1,
                           sort_by: str="review_count",
                           api_key: str = Depends(get_api_key)):
    
    try:
        open_businesses = await fetch_nearby_locations(latitude, longitude, limit, radius, categories, cur_open, sort_by)
        return open_businesses
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

    
#########################
### Message retrieval ###
#########################

# Retrieves chat context
def retrieve_thread_id(session_id):
    thread_id = redis_client.get(session_id)
    return thread_id

# Updates chat context
def update_thread_id(session_id, thread_id):
    redis_client.set(session_id, thread_id)
    return thread_id

# Retrieves user preference
def retrieve_user_preference(user_id):
    user_preference = redis_client.lrange(user_id, 0, -1)
    return user_preference

# Updates user preference
def update_user_preference(user_id, new_preferences):
    key_type = redis_client.type(user_id)
    current_preferences = set()
    if key_type == b'list':
        current_preferences = set(redis_client.lrange(user_id, 0, -1).decode('utf-8'))
    elif key_type != b'none':
        redis_client.delete(user_id)

    new_preferences_set = set(new_preferences)
    updated_preferences = current_preferences.union(new_preferences_set)
    if updated_preferences:
        updated_preferences = [pref.decode('utf-8') if isinstance(pref, bytes) else pref for pref in updated_preferences]
        redis_client.delete(user_id)  # Clear existing data
        redis_client.rpush(user_id, *updated_preferences)
    
    return updated_preferences

# User initial inference
async def user_inference(chat_history):

    # response validation
    valid_limit = [1, 50, 10]  # min, max, default
    valid_radius = [10, 100000, 10000]  # min, max, default
    valid_cur_open = [0, 1, 1]  # closed, open, default
    valid_categories = ["restaurants", "food", "shopping", "fitness", "beautysvc", "hiking", "aquariums", "coffee", "all"]
    valid_sort_by = ["review_count", "rating", "best_match", "distance"]
    
    # Prepare the prompt
    few_shot_examples = [
        {"role": "assistant", "content": "You are a helpful assistant. Analyze the user's conversation and infer their preferences for visiting places in JSON format, including limit, radius, categories, cur_open, and sort_by. Ensure the category is one from the following list: restaurants, food, shopping, fitness, beautysvc, hiking, aquariums, coffee, all. The sort_by option must be one of the following: review_count, rating, best_match, distance."},
        {"role": "user", "content": "I love spending my evenings at a quiet coffee shop reading a book."},
        {"role": "assistant", "content": "{\"limit\": 5, \"radius\": 5000, \"categories\": \"coffee\", \"cur_open\": 1, \"sort_by\": \"rating\"}"},
        {"role": "user", "content": "I'm looking for a gym to start working out."},
        {"role": "assistant", "content": "{\"limit\": 10, \"radius\": 10000, \"categories\": \"fitness\", \"cur_open\": 1, \"sort_by\": \"distance\"}"}
    ]

    # add examples with chat history
    structured_chat_history = few_shot_examples + chat_history

    try:
        response = openai_client.chat.completions.create(
            model="gpt-3.5-turbo-0125",
            response_format={ "type": "json_object" },
            messages=structured_chat_history
        )

        inferences_str = response.choices[0].message.content
        print(inferences_str)
        inferred_preferences = json.loads(inferences_str)

        # Validate and adjust the 'limit'
        limit = inferred_preferences.get("limit", valid_limit[2])
        inferred_preferences["limit"] = max(min(limit, valid_limit[1]), valid_limit[0])

        # Validate and adjust the 'radius'
        radius = inferred_preferences.get("radius", valid_radius[2])
        inferred_preferences["radius"] = max(min(radius, valid_radius[1]), valid_radius[0])

        # Validate and adjust the 'cur_open'
        cur_open = inferred_preferences.get("cur_open", valid_cur_open[2])
        inferred_preferences["cur_open"] = cur_open if cur_open in valid_cur_open[:2] else valid_cur_open[2]

        # Validate and adjust the 'categories'
        category = inferred_preferences.get("categories", "all").lower()
        inferred_preferences["categories"] = category if category in valid_categories else "all"

        # Validate and adjust the 'sort_by'
        sort_by = inferred_preferences.get("sort_by", "review_count").lower()
        inferred_preferences["sort_by"] = sort_by if sort_by in valid_sort_by else "review_count"

        return inferred_preferences

    except Exception as e:
        print(f"Error during inference: {e}")
        # Return default preferences in case of an error
        return {
            "limit": valid_limit[2],
            "radius": valid_radius[2],
            "cur_open": valid_cur_open[2],
            "categories": "all",
            "sort_by": "review_count"
        }

async def fetch_nearby_locations_inferred(latitude:float, 
                                          longitude:float,
                                          thread_id:str):
    
    chat_history = openai_client.beta.threads.messages.list(
        thread_id=thread_id,
        order="asc"
    )

    chat_history_contents = []
    for message in chat_history:
        chat_history_contents.append({"role": message.role, "content": message.content[0].text.value})

    parameters = await user_inference(chat_history_contents)
    potential_locations = await fetch_nearby_locations(
        latitude=latitude,
        longitude=longitude,
        limit=parameters["limit"],
        radius=parameters["radius"],
        categories=parameters["categories"],
        cur_open=parameters["cur_open"],
        sort_by=parameters["sort_by"]
    )
    return potential_locations
    

# Returns the entire prompt for ChatGPT
def retrieve_complete_prompt(chat_context, user_preference, nearby_locations, rec_limit=10):
    pass

# Response of chatgpt for search tab
@app.post("/chatgpt_response")
async def chatgpt_response(user_id: str="1234", 
                           session_id: str="1234",
                           message: str="asflaj",
                           latitude: float=32.8723812680163,
                           longitude: float=-117.21242234341588,
                           api_key: str = Depends(get_api_key)):

    
    # thread_id = retrieve_thread_id(session_id)
    # user_preferences = retrieve_user_preference(user_id)
    # return await fetch_nearby_locations_inferred(latitude=latitude, longitude=longitude, thread_id=thread_id)

    tools = [
        {
            "type": "function",
            "function": {
                "name": "fetch_nearby_locations_inferred",
                "description": "Retrieve the locations of potential places for users to visit",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "latitude": {
                            "type": "float",
                            "description": "The latitude of a specified location, e.g. 36.1513871523."
                        },
                        "longitude": {
                            "type": "float",
                            "description": "The longitude of a specified location, e.g. -86.7966029393."
                        },
                        "thread_id": {
                            "type": "string",
                            "description": "The thread id between ChatGPT and the user, e.g. 'thread_6FZiR5M0XbgysqRDZIM9S8RU'."
                        }
                    },
                    "required": ["latitude", "longitude", "thread_id"],
                },
            },
        }
    ]

    instructions = "You are an intelligent assistant for the WhatNext? app, designed to suggest places to visit, eat, and things to do based on user preferences. Your goal is to understand user requests and provide personalized recommendations. Follow these steps when interacting with users:\n1. Listen for user messages indicating they are seeking suggestions for places to visit, eat, or activities. Look for keywords like 'looking for', 'suggest', or specific types of places or activities mentioned.\n2. Once you detect a request for suggestions, trigger fetch_nearby_locations_inferred. The inputs latitude, longitude, and thread_id are defined in the code. Fetch and present the user with a list of recommended places or activities based on their inferred preferences. 4. Provide detailed information about the recommendations, including names, locations, and why they match the user's preferences. Encourage the user to ask more questions or refine their preferences for more tailored suggestions. Remember, your primary role is to assist users in discovering new experiences that align with their interests and preferences. Use the tools at your disposal to create a responsive and personalized service."
    
    assistant = openai_client.beta.assistants.create(
        instructions="You are a location recommendation system. ",
        model="gpt-4-1106-preview",
        tools=tools
    )

    # thread = openai_client.beta.threads.create()
    # message = openai_client.beta.threads.messages.create(
    #     thread_id = thread.id,
    #     role="user",
    #     content="I'm feeling hungry. Can you recommend me some places to eat?",
    # )

    # run = openai_client.beta.threads.runs.create(
    #     thread_id = thread.id,
    #     assistant_id = assistant.id
    # )

    # print(run.model_dump_json(indent=4))
