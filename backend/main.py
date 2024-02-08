from fastapi import FastAPI, Security, HTTPException, Depends
from fastapi.security.api_key import APIKeyHeader
from starlette.status import HTTP_403_FORBIDDEN
from pymongo import MongoClient
import motor.motor_asyncio
from typing import List, Optional, Dict
from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime, timedelta
import pytz
from openai import OpenAI
import requests
import redis
import json
import uuid
import time
import re

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

class ChatRequest(BaseModel):
    user_id: str
    session_id: Optional[str] = Field(None, description="The session ID for the chat session, if available.")
    message: str
    latitude: float = Field(..., description="Latitude for the location-based query.")
    longitude: float = Field(..., description="Longitude for the location-based query.")

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
                                 limit: int=10, 
                                 radius: float=10000, 
                                 categories: str="all", 
                                 cur_open: int=1, 
                                 sort_by: str="best_match") -> List[Location]:

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

    if "," in categories:
        categories_list = [cat.strip() for cat in categories.split(",")]
    else:
        categories_list = [categories.strip()]

    regex_pattern = '|'.join(f"(^|, ){re.escape(cat)}(,|$)" for cat in categories_list)

    if categories_list != ["any"]:
        query["categories"] = {"$regex": regex_pattern, "$options": "i"}

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

# Generate new session id
def generate_unique_session_id():
    return str(uuid.uuid4())

# Generate new thread id
def generate_thread_id():
    thread = openai_client.beta.threads.create()
    return thread.id

# Generate new assistant id
def generate_assistant_id():
    valid_limit = [1, 50, 10]
    valid_radius = [1000, 100000, 10000]
    valid_cur_open = [0, 1, 1] 
    valid_categories = ["restaurant", "food", "shopping", "fitness", "beautysvc", "hiking", "aquariums", "coffee", "all"]
    valid_sort_by = ["review_count", "rating", "best_match", "distance"]
    tools = [
        {
            "type": "function",
            "function": {
                "name": "fetch_nearby_locations",
                "description": "Retrieve the locations of potential places for users to visit",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "limit": {
                            "type": "string",
                            "description": f"Specifies the number of locations to retrieve. Range: {valid_limit[0]}-{valid_limit[1]}, Default: {valid_limit[2]}."
                        },
                        "radius": {
                            "type": "string",
                            "description": f"Defines the search radius in meters. Range: {valid_radius[0]}-{valid_radius[1]}, Default: {valid_radius[2]}."
                        },
                        "categories": {
                            "type": "string",
                            "description": f"Categories to filter the search. Options: {', '.join(valid_categories[:-1])}, or {valid_categories[-1]}."
                        },
                        "cur_open": {
                            "type": "string",
                            "description": f"Filter based on current open status. 0 for closed, 1 for open. Default: {valid_cur_open[2]}."
                        },
                        "sort_by": {
                            "type": "string",
                            "description": f"Sorts the results by the specified criteria. Options: {', '.join(valid_sort_by[:-1])}, or {valid_sort_by[-1]}."
                        }
                    },
                },
            },
        }
    ]
    instructions = "You are an intelligent assistant for the WhatNext? app, designed to suggest places to visit, eat, and things to do based on user preferences. Your goal is to understand user requests and provide personalized recommendations. Follow these steps when interacting with users:\n1. Listen for user messages indicating they are seeking suggestions for places to visit, eat, or activities. Look for keywords like 'looking for', 'suggest', or specific types of places or activities mentioned.\n2. Once you detect a request for suggestions, trigger fetch_nearby_locations. The inputs latitude, longitude, and thread_id are defined in the code. Fetch and present the user with a list of recommended places or activities based on their inferred preferences. 4. Provide detailed information about the recommendations, including names, locations, and why they match the user's preferences. Encourage the user to ask more questions or refine their preferences for more tailored suggestions. Remember, your primary role is to assist users in discovering new experiences that align with their interests and preferences. Use the tools at your disposal to create a responsive and personalized service."
    assistant = openai_client.beta.assistants.create(
        instructions=instructions,
        model="gpt-4-1106-preview",
        tools=tools
    )
    return assistant.id

# Retrieves thread_id and assistant_id based on session_id
def retrieve_chat_info(session_id):
    if session_id is None or not redis_client.exists(session_id):
        session_id = generate_unique_session_id()
        thread_id = generate_thread_id()
        assistant_id = generate_assistant_id()
        redis_client.hset(session_id, mapping={"thread_id": thread_id, "assistant_id": assistant_id})
    values = redis_client.hgetall(session_id)
    thread_id = values.get("thread_id")
    assistant_id = values.get("assistant_id")
    return session_id, thread_id, assistant_id

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

    # remove any duplicates
    new_preferences_set = set(new_preferences)
    updated_preferences = current_preferences.union(new_preferences_set)
    if updated_preferences:
        updated_preferences = [pref.decode('utf-8') if isinstance(pref, bytes) else pref for pref in updated_preferences]
        redis_client.delete(user_id)
        redis_client.rpush(user_id, *updated_preferences)
    
    return updated_preferences

# Response of chatgpt for search tab
@app.post("/chatgpt_response")
async def chatgpt_response(request: ChatRequest,
                           api_key: str = Depends(get_api_key)):

    user_id = request.user_id
    session_id = request.session_id
    message = request.message
    latitude = request.latitude
    longitude = request.longitude

    # return await fetch_nearby_locations(latitude=latitude, longitude=longitude)

    session_id, thread_id, assistant_id = retrieve_chat_info(session_id)
    print({"s": session_id, "t": thread_id, "a": assistant_id})

    user_message = openai_client.beta.threads.messages.create(
        thread_id = thread_id,
        role="user",
        content=message,
    )

    run = openai_client.beta.threads.runs.create(
        thread_id = thread_id,
        assistant_id = assistant_id,
    )

    run_status = openai_client.beta.threads.runs.retrieve(
        thread_id=thread_id,
        run_id=run.id
    )

    while True:
        run_status = openai_client.beta.threads.runs.retrieve(
            thread_id=thread_id,
            run_id=run.id
        )

        if run_status.status == 'completed':
            chat_type = "regular"
            messages = openai_client.beta.threads.messages.list(
                thread_id=thread_id,
                order="desc"
            )
            for msg in messages.data:
                message_content = msg.content[0].text.value
                print(message_content)
                
            return {"user_id": user_id, "session_id": session_id, "message_content": message_content, "chat_type": chat_type}
        
        elif run_status.status == 'requires_action':
            print("Function Calling")
            chat_type = "function"
            required_actions = run_status.required_action.submit_tool_outputs.model_dump()
            tool_outputs = []
            for action in required_actions["tool_calls"]:
                func_name = action['function']['name']
                arguments = json.loads(action['function']['arguments'])
                if "limit" not in arguments:
                    arguments["limit"] = 10
                if "radius" not in arguments:
                    arguments["radius"] = 10000
                if "categories" not in arguments:
                    arguments["categories"] = "all"
                if "cur_open" not in arguments:
                    arguments["cur_open"] = 0
                if "sort_by" not in arguments:
                    arguments["sort_by"] = "best_match"

                if func_name == "fetch_nearby_locations":
                    output = await fetch_nearby_locations(latitude=float(latitude), 
                                                        longitude=float(longitude), 
                                                        limit=int(arguments["limit"]), 
                                                        radius=int(arguments["radius"]), 
                                                        categories=arguments["categories"], 
                                                        cur_open=int(arguments["cur_open"]), 
                                                        sort_by=arguments["sort_by"])
                    output_dicts = [loc.model_dump() for loc in output]
                    output_str = json.dumps(output_dicts, ensure_ascii=False)
                    tool_outputs.append({
                        "tool_call_id": action['id'],
                        "output": output_str
                    })
                    
                else:
                    raise ValueError(f"Unknown function: {func_name}")
                
            print("Submitting outputs back to the Assistant...")
            openai_client.beta.threads.runs.submit_tool_outputs(
                thread_id=thread_id,
                run_id=run.id,
                tool_outputs=tool_outputs
            )

        else:
            continue
