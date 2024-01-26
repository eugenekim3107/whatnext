from fastapi import FastAPI, HTTPException
import httpx

app = FastAPI()

YELP_API_KEY = 'sMFOsH94cd7UX9DqgoU56plsTC9C4MWkaigY9r4yQMELhtCAwbRzYgDLymy9qreZl6YXWyXo5lznGIWmCi7xTFr1BG3JJx5nYT70WEjPuveXBqKbrTFU5ROVk82mZXYx'
OPENAI_API_KEY = 'your_openai_api_key'

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

@app.post("/recommendations")
async def recommendations(latitude: float, longitude: float, user_preference: str):
    yelp_data = await fetch_yelp_data(latitude, longitude)
    sorted_recommendations = await get_sorted_recommendations(yelp_data, user_preference)
    return sorted_recommendations
