from fastapi import FastAPI, HTTPException
import httpx
import requests
from typing import List
from pydantic import BaseModel

app = FastAPI()

YELP_API_KEY = 'sMFOsH94cd7UX9DqgoU56plsTC9C4MWkaigY9r4yQMELhtCAwbRzYgDLymy9qreZl6YXWyXo5lznGIWmCi7xTFr1BG3JJx5nYT70WEjPuveXBqKbrTFU5ROVk82mZXYx'
OPENAI_API_KEY = 'your_openai_api_key'

#model for each bussiness instance
class bussiness(BaseModel):
    rating: str
    id:str
    image_url:str
    review_count:str
    is_closed:str
    name:str
    latitude:str
    longitude:str
    tag:List
    contact:str
    distance:str
    price:str
    address:str

# model for location input as json
class Coordinates(BaseModel):
    latitude: float
    longitude: float
    


@app.get("/")
def root():
    return "Welcome To WhatNext API Home"

async def fetch_yelp_data(latitude: float, longitude: float):
    url = "https://api.yelp.com/v3/businesses/search"
    headers = {"Authorization": f"Bearer {YELP_API_KEY}"}
    params = {"latitude": latitude, "longitude": longitude}
    
    async with httpx.AsyncClient() as client:
        response = await client.get(url, headers=headers, params=params)

    if response.status_code != 200:
        raise HTTPException(status_code=400, detail="Error in Yelp API call")
    
    return response.json()

async def get_sorted_recommendations(yelp_data, user_preference):
    prompt = f"Sort these businesses based on the user preference '{user_preference}': {yelp_data}"
    url = "https://api.openai.com/v1/engines/davinci-codex/completions"
    headers = {"Authorization": f"Bearer {OPENAI_API_KEY}"}
    json_data = {"prompt": prompt, "max_tokens": 500}

    async with httpx.AsyncClient() as client:
        response = await client.post(url, headers=headers, json=json_data)

    if response.status_code != 200:
        raise HTTPException(status_code=400, detail="Error in OpenAI API call")

    return response.json()

# search nearby restaurants by geo location,sorted by rating, and only return places are currently open
@app.post("/recommendations/")
async def recommendations(latitude: float, longitude: float, user_preference: str):
    yelp_data = await fetch_yelp_data(latitude, longitude)
    sorted_recommendations = await get_sorted_recommendations(yelp_data, user_preference)
    return sorted_recommendations


@app.post("/search_near/")
async def recommendations(coord:Coordinates)-> List[bussiness]:
    yelp_data = await search_nearby_restaurants(YELP_API_KEY,coord.latitude,coord.longitude,include_reviews=False)
    return yelp_data
    


async def search_nearby_restaurants(api_key, latitude, longitude, categories='restaurants',radius=20000,cur_open=True,sort_by="rating",include_reviews=True,limit=10):
    headers = {'Authorization': f'Bearer {api_key}'}
    url = 'https://api.yelp.com/v3/businesses/search'
    params = {'latitude': latitude, 'longitude': -1*longitude,"categories": categories,"radius":radius,"limit":limit,'open_now':cur_open,"sort_by":sort_by}

    async with httpx.AsyncClient() as client:
        response = await client.get(url, headers=headers, params=params)
    if response.status_code!=200:
        raise HTTPException(status_code=400, detail="Error in Yelp API search call")
    data = response.json()
    if include_reviews:
        res = [{"rating":d["rating"] if "rating" in d else None,
               "id":d["id"] if "id" in d else None,
               "image_url":d['image_url'] if 'image_url' in d else None,
                "is_closed":d["is_closed"] if "is_closed" in d else None,
                "review_count":d["review_count"] if "review_count" in d else None,
                "name":d["name"] if "name" in d else None,
                "latitude":d["coordinates"]['latitude'] if "coordinates" in d and 'latitude' in d["coordinates"] else None,
                "longitude":d["coordinates"]['longitude'] if "coordinates" in d and 'longitude' in d["coordinates"] else None,
                "tag":str([alias["alias"] for alias in d['categories']]),
                "contact":d["phone"] if "contact" in d else None,
                "distance":d["distance"] if "distance" in d else None,
                "price":str(d["price"]) if "price" in d else None,
                "address":' ,'.join(d['location']['display_address']) if "location" in d and "display_address" in d['location'] else None,
                "reviews":get_reviews(api_key,d["id"])} for d in data['businesses']]
    else:
        res = [{"rating":str(d["rating"]) if "rating" in d else "",
               "id":str(d["id"]) if "id" in d else "",
               "image_url":str(d['image_url']) if 'image_url' in d else "",
                "review_count":str(d["review_count"]) if "review_count" in d else "",
                "is_closed":str(d["is_closed"]) if "is_closed" in d else "",
                "name":str(d["name"]) if "name" in d else "",
                "latitude":str(d["coordinates"]['latitude']) if "coordinates" in d and 'latitude' in d["coordinates"] else "",
                "longitude":str(d["coordinates"]['longitude']) if "coordinates" in d and 'longitude' in d["coordinates"] else "",
                "tag":[alias["alias"] for alias in d['categories']],
                "contact":str(d["phone"]) if "phone" in d else "",
                "distance":str(d["distance"]) if "distance" in d else "",
                "price":str(d["price"]) if "price" in d else "",
                "address":' ,'.join(d['location']['display_address']) if "location" in d and "display_address" in d['location'] else ""} for d in data['businesses']]

    return res


async def get_reviews(api_key, business_id):
    headers = {'Authorization': f'Bearer {api_key}'}
    url = f'https://api.yelp.com/v3/businesses/{business_id}/reviews'
    
    response = requests.get(url, headers=headers)
    if response.status_code !=200:
        raise HTTPException(status_code=400, detail="Error in Yelp API Review Call")
    data = response.json()
    res = [r["text"] for r in data["reviews"]]
    return res
