from fastapi import FastAPI, Security, HTTPException, Depends
from fastapi.security.api_key import APIKeyHeader
from starlette.status import HTTP_403_FORBIDDEN
from pymongo import MongoClient
from typing import List, Optional, Dict
from pydantic import BaseModel
from datetime import datetime, timedelta
import pytz

# API key credentials
API_KEY = "whatnext"
API_KEY_NAME = "whatnext_token"
api_key_header = APIKeyHeader(name=API_KEY_NAME, auto_error=False)

# MongoDB (make sure to change the ip address to match the ec2 instance ip address)
client = MongoClient("mongodb://eugenekim:whatnext@localhost:8000/")
db = client["locationDatabase"]

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
    location: GeoJSON
    stars: Optional[float] = None
    review_count: int = 0
    attributes: Optional[Dict[str, str]] = None
    categories: Optional[str] = None
    hours: Optional[Dict[str, str]] = None

app = FastAPI()

async def get_api_key(api_key: str = Security(api_key_header)):
    if api_key == API_KEY:
        return api_key
    else:
        raise HTTPException(
            status_code=HTTP_403_FORBIDDEN, detail="Invalid API Key"
        )

def is_within_hours(now, hours_str):
    if not hours_str or hours_str == "0:0-0:0":
        return False
    open_time_str, close_time_str = hours_str.split('-')
    open_hour, open_minute = map(int, open_time_str.split(':'))
    close_hour, close_minute = map(int, close_time_str.split(':'))

    open_time = now.replace(hour=open_hour, minute=open_minute, second=0, microsecond=0)
    close_time = now.replace(hour=close_hour, minute=close_minute, second=0, microsecond=0)
    
    if close_time < open_time:
        close_time = close_time + timedelta(days=1)
    
    return open_time <= now <= close_time

@app.get("/nearby_locations", response_model=List[Location])
async def nearby_locations(latitude: float=36.1513871523,
                           longitude: float=-86.7966029393,
                           limit: int=1,
                           radius: float=10000.0,
                           categories: str="any", # 'any' is all categories
                           cur_open: int=1,
                           sort_by: str="review_count",
                           api_key: str = Depends(get_api_key)):
    
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
        items = db.locations.find(query).sort(sort_by, -1).limit(limit)
        open_businesses = []

        for item in items:
            day_of_week = now.strftime('%A')
            hours_str = item.get('hours', {}).get(day_of_week, "")

            if cur_open != 1 or (cur_open == 1 and is_within_hours(now, hours_str)):
                open_businesses.append(Location(**item))

        return open_businesses
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
