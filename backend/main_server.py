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
import os
import pytz

##############################
### Setup and requirements ###
##############################

# API key credentials
API_KEY = os.getenv('whatnext_token')
API_KEY_NAME = "whatnext_token"
api_key_header = APIKeyHeader(name=API_KEY_NAME, auto_error=False)

# MongoDB (make sure to change the ip address to match the ec2 instance ip address)
MONGO_DETAILS = "mongodb://eugenekim:whatnext@172.31.28.141:27017/"
mongo_client = motor.motor_asyncio.AsyncIOMotorClient(MONGO_DETAILS)
db = mongo_client["locationDatabase"]

# OpenAI
openai_client = OpenAI(api_key=os.getenv('OPENAI_API_KEY'))

# Redis server for chat and user history
redis_client = redis.Redis(host='172.31.28.141', port=6379, db=0, decode_responses=True)

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
    cur_open: Optional[int] = 0
    categories: Optional[str] = None
    tag: Optional[List[str]] = None
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
                                 limit: int=30, 
                                 radius: float=10000, 
                                 categories: str="all", 
                                 cur_open: int=0, 
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
    }

    if "," in categories:
        categories_list = [cat.strip() for cat in categories.split(",")]
    else:
        categories_list = [categories.strip()]

    regex_pattern = '|'.join(f"(^|, ){re.escape(cat)}(,|$)" for cat in categories_list)

    if categories_list != ["any"]:
        query["categories"] = {"$regex": regex_pattern, "$options": "i"}

    pacific = pytz.timezone('America/Los_Angeles')
    now_utc = datetime.now(pytz.utc)
    now = now_utc.astimezone(pacific)

    try:
        items = await db.locations.find(query).sort(sort_by, -1).limit(limit).to_list(length=limit)
        open_businesses = []

        for item in items:
            perm_status = item['cur_open']
            item['cur_open'] = 0
            day_of_week = now.strftime('%A')
            hours_list = item.get('hours', {}).get(day_of_week)

            if perm_status == 1 and is_within_hours(now, hours_list):
                item['cur_open'] = 1
                open_businesses.append(Location(**item))
            if cur_open == 0:
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
                                           cur_open: int=0, 
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
    }

    if "," in categories:
        categories_list = [cat.strip() for cat in categories.split(",")]
    else:
        categories_list = [categories.strip()]

    regex_pattern = '|'.join(f"(^|, ){re.escape(cat)}(,|$)" for cat in categories_list)

    if categories_list != ["any"]:
        query["categories"] = {"$regex": regex_pattern, "$options": "i"}

    pacific = pytz.timezone('America/Los_Angeles')
    now_utc = datetime.now(pytz.utc)
    now = now_utc.astimezone(pacific)

    try:
        items = await db.locations.find(query).sort(sort_by, -1).limit(limit).to_list(length=limit)
        open_businesses = []

        for item in items:
            perm_status = item['cur_open']
            item['cur_open'] = 0
            day_of_week = now.strftime('%A')
            hours_list = item.get('hours', {}).get(day_of_week)

            if perm_status == 1 and is_within_hours(now, hours_list):
                item['cur_open'] = 1
                open_businesses.append(LocationCondensed(**item))
            if cur_open == 0:
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

async def fetch_specific_location(business_id: str) -> Optional[Location]:
    query = {"business_id": business_id}
    try:
        item = await db.locations.find_one(query)
        if item:
            return Location(**item)
        else:
            return None
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

# Retrieve nearby businesses based on location, time, category, and radius
@app.get("/api/nearby_locations", response_model=List[Location])
async def nearby_locations(latitude: float=32.8723812680163,
                           longitude: float=-117.21242234341588,
                           limit: int=20,
                           radius: float=10000.0,
                           categories: str="any", # 'any' is all categories
                           cur_open: int=0,
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
@app.post("/api/chatgpt_response")
async def chatgpt_response(request: ChatRequest,
                           api_key: str = Depends(get_api_key)):
    start = time.time()
    user_id = request.user_id
    session_id = request.session_id
    message = request.message
    latitude = request.latitude
    longitude = request.longitude

    # return await fetch_nearby_locations_condensed(latitude=latitude, longitude=longitude)d
    session_id, thread_id, assistant_id = retrieve_chat_info(session_id, redis_client, openai_client)

    openai_client.beta.threads.messages.create(
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

    output_nearby_locations = None
    output_specific_location = None

    while run_status.status != 'completed':

        run_status = openai_client.beta.threads.runs.retrieve(
            thread_id=thread_id,
            run_id=run.id
        )
        
        if run_status.status == 'requires_action':
            required_actions = run_status.required_action.submit_tool_outputs.model_dump()
            default_args = {
                "limit": 10,
                "radius": 10000,
                "categories": "all",
                "cur_open": 1,
                "sort_by": "best_match"
            }
            # Validation ranges and sets
            valid_limit_range = [3, 10]  # min, max
            valid_radius_range = [1000, 100000]  # min, max
            valid_cur_open_options = [0, 1]  # closed or open
            categories_file_path = "categories.json"
            valid_categories = open_json_file(categories_file_path)
            valid_sort_by_options = ["review_count", "rating", "best_match", "distance"]

            tool_outputs = []

            for action in required_actions["tool_calls"]:

                func_name = action['function']['name']
                arguments = json.loads(action['function']['arguments']) if action['function']['arguments'] else {}
                arguments = {**default_args, **arguments}

                # Check the function call name
                if func_name == "fetch_nearby_locations_condensed":

                    # Validate and update arguments
                    arguments["limit"] = max(min(int(arguments["limit"]), valid_limit_range[1]), valid_limit_range[0]) if "limit" in arguments else default_args["limit"]
                    arguments["radius"] = max(min(int(arguments["radius"]), valid_radius_range[1]), valid_radius_range[0]) if "radius" in arguments else default_args["radius"]
                    arguments["categories"] = arguments["categories"] if arguments["categories"] in valid_categories else default_args["categories"]
                    arguments["cur_open"] = int(arguments["cur_open"]) if int(arguments["cur_open"]) in valid_cur_open_options else default_args["cur_open"]
                    arguments["sort_by"] = arguments["sort_by"] if arguments["sort_by"] in valid_sort_by_options else default_args["sort_by"]
                
                    output_nearby_locations = await fetch_nearby_locations_condensed(
                        latitude=float(latitude), 
                        longitude=float(longitude), 
                        limit=30,
                        radius=int(arguments["radius"]), 
                        categories=arguments["categories"], 
                        cur_open=int(arguments["cur_open"]), 
                        sort_by=arguments["sort_by"]
                    )

                    if len(output_nearby_locations) == 0:
                        business_info = "All nearby locations are either currently closed or unavaliable."
                    else:
                        business_info = ', '.join([location.name for location in output_nearby_locations if location.name is not None])
                    tool_output = {
                        "tool_call_id": action["id"],
                        "output": business_info
                    }

                    tool_outputs.append(tool_output)
                
                elif func_name == "fetch_specific_location":

                    # Validate business_id
                    arguments["business"] = arguments["business_id"] if arguments["business_id"] is not None else ""

                    output_specific_location = await fetch_specific_location(
                        business_id=arguments["business_id"]
                    )

                    if output_specific_location is None:
                        business_info = "No additional information about location"
                    else:
                        business_info = f"{output_specific_location}"
                    tool_output = {
                        "tool_call_id": action["id"],
                        "output": business_info
                    }
                    tool_outputs.append(tool_output)
                
                else:
                    continue

            openai_client.beta.threads.runs.submit_tool_outputs(
                thread_id=thread_id,
                run_id=run.id,
                tool_outputs=tool_outputs
            )
        
        else:
            continue
    
    if output_nearby_locations is None or len(output_nearby_locations) == 0:
        chat_type = "regular"
        messages = openai_client.beta.threads.messages.list(
            thread_id=thread_id,
            order="asc"
        )
        for msg in messages.data:
            message_content = msg.content[0].text.value
        end = time.time()
        return {"user_id": user_id, "session_id": session_id, "content": message_content, "chat_type": chat_type, "is_user_message": "false"}
    
    else:
        # Additional steps when locations are recommended
        sort_message = f"{output_nearby_locations}"
        openai_client.beta.threads.messages.create(
            thread_id = thread_id,
            role="user",
            content=sort_message,
        )
        
        run_sort_id = create_sorting_run(openai_client, thread_id, assistant_id)

        run_sort_status = openai_client.beta.threads.runs.retrieve(
            thread_id=thread_id,
            run_id=run_sort_id
        )

        while run_sort_status.status != 'completed':
            run_sort_status = openai_client.beta.threads.runs.retrieve(
                thread_id=thread_id,
                run_id=run_sort_id
            )
            continue
        
        chat_type = "locations"
        messages = openai_client.beta.threads.messages.list(
            thread_id=thread_id,
            order="desc"
        )
        business_ids = messages.data[0].content[0].text.value
        business_ids_top_k = business_ids.split(", ")[:int(arguments["limit"])]
        personalized_locations = await fetch_locations_business_id(business_ids_top_k)

        end = time.time()
        return {"user_id": user_id, "session_id": session_id, "content": personalized_locations, "chat_type": chat_type, "is_user_message": "false"}
