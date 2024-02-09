from fastapi import FastAPI, Security, HTTPException, Depends
from utils import *
from fastapi.security.api_key import APIKeyHeader
from starlette.status import HTTP_403_FORBIDDEN
import motor.motor_asyncio
from typing import List, Optional, Dict
from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
from openai import OpenAI
import redis
import json
import re
import time

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
    image_url: Optional[str] = None
    phone: Optional[str] = None
    display_phone: Optional[str] = None
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

class LocationCondensed(BaseModel):
    business_id: str
    name: Optional[str] = None
    stars: Optional[float] = None
    review_count: Optional[float] = None
    cur_open: Optional[float] = 0
    categories: Optional[float] = None
    tag: Optional[float] = None
    price: Optional[str] = None

# Verifies correct api key
async def get_api_key(api_key: str = Security(api_key_header)):
    if api_key == API_KEY:
        return api_key
    else:
        raise HTTPException(
            status_code=HTTP_403_FORBIDDEN, detail="Invalid API Key"
        )

# Retrieve nearby locations
async def fetch_nearby_locations(latitude: float, 
                                 longitude: float, 
                                 limit: int=50, 
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
    
# Retrieve nearby locations with condensed information
async def fetch_nearby_locations_condensed(latitude: float, 
                                           longitude: float, 
                                           limit: int=50, 
                                           radius: float=10000, 
                                           categories: str="all", 
                                           cur_open: int=1, 
                                           sort_by: str="best_match") -> List[LocationCondensed]:
    
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

            open_businesses.append(LocationCondensed(**item))

        return open_businesses
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
async def fetch_locations_business_id(business_ids: List[str]):
    query = {
        "business_id": {"$in": business_ids}
    }

    try:
        items = await db.locations.find(query).to_list(None)
        items_dict = {item['business_id']: item for item in items}
        ordered_items = [items_dict[business_id] for business_id in business_ids if business_id in items_dict]
        locations = [Location(**item) for item in ordered_items]
        return locations
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

# Response of chatgpt for search tab
@app.post("/chatgpt_response")
async def chatgpt_response(request: ChatRequest,
                           api_key: str = Depends(get_api_key)):
    start = time.time()
    user_id = request.user_id
    session_id = request.session_id
    message = request.message
    latitude = request.latitude
    longitude = request.longitude

    # return await fetch_nearby_locations(latitude=latitude, longitude=longitude)
    sort_assistant_id = generate_sort_assistant_id(openai_client)
    session_id, thread_id, assistant_id = retrieve_chat_info(session_id, redis_client, openai_client)
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
            print("Generating regular response...")
            chat_type = "regular"
            messages = openai_client.beta.threads.messages.list(
                thread_id=thread_id,
                order="asc"
            )
            for msg in messages.data:
                message_content = msg.content[0].text.value
            end = time.time()
            print(end-start)
            return {"user_id": user_id, "session_id": session_id, "content": message_content, "chat_type": chat_type}
        
        elif run_status.status == 'requires_action':
            required_actions = run_status.required_action.submit_tool_outputs.model_dump()
            default_args = {
                "limit": 10,
                "radius": 10000,
                "categories": "all",
                "cur_open": 1,
                "sort_by": "best_match"
            }
            for action in required_actions["tool_calls"]:
                arguments = json.loads(action['function']['arguments']) if action['function']['arguments'] else {}
                arguments = {**default_args, **arguments}

                print("Fetching nearby locations...")
                
                output = await fetch_nearby_locations_condensed(
                    latitude=float(latitude), 
                    longitude=float(longitude), 
                    limit=20, 
                    radius=int(arguments["radius"]), 
                    categories=arguments["categories"], 
                    cur_open=int(arguments["cur_open"]), 
                    sort_by=arguments["sort_by"]
                )

            run = openai_client.beta.threads.runs.cancel(
                thread_id=thread_id,
                run_id=run.id
            )

            sort_message = f"{output}"
            openai_client.beta.threads.messages.create(
                thread_id = thread_id,
                role="user",
                content=sort_message,
            )

            print("Sorting locations based on personal preference...")

            run = openai_client.beta.threads.runs.create(
                thread_id=thread_id,
                assistant_id=sort_assistant_id
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
                    chat_type = "locations"
                    messages = openai_client.beta.threads.messages.list(
                        thread_id=thread_id,
                        order="desc"
                    )
                    business_ids = messages.data[0].content[0].text.value
                    business_ids_top_k = business_ids.split(", ")[:int(arguments["limit"])]
                    print("Retrieving filtered personalized locations...")
                    personalized_locations = await fetch_locations_business_id(business_ids_top_k)
                    end = time.time()
                    print(end-start)
                    return {"user_id": user_id, "session_id": session_id, "content": personalized_locations, "chat_type": chat_type}

                else:
                    continue

        else:
            continue
