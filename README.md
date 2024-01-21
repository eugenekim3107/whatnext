# WhatNext?

## Introduction
WhatNext? is an innovative mobile application designed to streamline the process of planning outings and activities. Leveraging the capabilities of GPT-4 and real-time location data, WhatNext? offers personalized and efficient recommendations for leisure activities, tailored to user preferences and current context.

## Team Members
- Eugene Kim
- Nicholas Lyu
- Mike Dong
- Jingbo Shang (Professor)

## Broad Problem Statement
In today's fast-paced world, finding suitable leisure activities can be time-consuming and overwhelming. WhatNext? addresses this issue by providing a user-friendly platform that offers real-time, personalized recommendations, reducing decision-making time and enhancing user experiences.

## Technology Stack
- Frontend: Swift/SwiftUI
- Backend: FastAPI
- Database: PostgreSQL, Redis
- Deployment: AWS
- APIs: Google Maps, GPT-4

## Key Features
- Real-Time Location Data Utilization
- Personalized User Experience
- Intuitive User Interface

## Development Setup

### Prerequisites
Before you begin, ensure you have the following installed:
- Docker
- Git

### Setting Up the Project
1. **Clone the Repository**
   - Clone the project repository to your local machine using:
     ```
     git clone https://github.com/eugenekim3107/whatnext.git
     ```

2. **Navigate to the Project Directory**
   - Change into the project directory:
     ```
     cd whatnext
     ```

3. **Pull the Docker Image**
   - You can pull the pre-built Docker image from GitHub Container Registry:
     ```
     docker pull ghcr.io/eugenekim3107/whatnext-docker-image:latest
     ```

4. **Run the Docker Container**
   - Once the image is pulled, start a container from the image:
     ```
     docker run --rm -it -p 8000:8000 ghcr.io/eugenekim3107/whatnext-docker-image:latest
     ```
     The `-p` flag maps a port on your local machine to a port in the Docker container (format: `local_port:container_port`). In this example, we're mapping port 8000 on the local machine to port 8000 in the container, which is the default port for FastAPI applications.

### Accessing the Application
- After the container starts, you should be able to access the FastAPI backend at `http://localhost:8000` and interact with the frontend as configured.

### Stopping the Container
- To stop the running Docker container, you can press `CTRL+C` in the terminal if it's running in the foreground, or use the `docker stop [CONTAINER ID]` command if it's running in the background.



### Yelp API
**general_info.json** is the scraped basic information restaurants in San Diego, you can use their business id to test functions.



Below is my yelp API, you can register a yelp api account and use yours.
`api_key = "sMFOsH94cd7UX9DqgoU56plsTC9C4MWkaigY9r4yQMELhtCAwbRzYgDLymy9qreZl6YXWyXo5lznGIWmCi7xTFr1BG3JJx5nYT70WEjPuveXBqKbrTFU5ROVk82mZXYx"`


If you want to use Serpapi, below is my api key 
`api_key = 'f7e8aa3da4f9e3df7389bf69b090ff50762319c0a8a8c954a967dcdcfdf59f41'`

Make sure to install the package first if you want to use it. 
`pip install google-search-results`

The `get_newest_reviews_by_id` function (with serpAPI) is commented currently, if you want to use it then just uncomment it and uncomment `from serpapi import GoogleSearch` at the top

Note: Each api key can only request 500 calls per day. When you set search_nearby_restaurants(include_reviews=True), it will execute up to 50 api calls when retrieving the reviews. So be careful to use it, or you can change the `limit` parameter to a smaller value if you want to find a limited amount of business nearby (the number of api calls is equal to the `limit`).

You can check the remaining calls by calling `check_api_calls_left(api_key)`














Usage Example:
**`search_nearby_restaurants(api_key, latitude, longitude, categories='restaurants',radius=20000,cur_open=True,sort_by="rating",include_reviews=True,limit=50)`**

Eg: **search_nearby_restaurants(api_key,32.88088,117.23790)**

This function outputs a **list** of dictionaries
`{'rating': 5.0,
  'id': 'Fp3c6U_r_8dK678CkNA1wQ',
  'image': 'https://s3-media1.fl.yelpcdn.com/bphoto/Evxqk0b0grsZMB4Yh4mbEg/o.jpg',
  'name': 'Carlitos Tacos Catering',
  'latitude': 32.72508,
  'longitude': -117.16433,
  'address': None,
  'transactions': [],
  'tag': ['tacos', 'catering'],
  'contact': '+16193892525',
  'reviews': [('Food, service, quality... everything exceptional!!! Love Carlitos Tacos Catering, the yummiest and food definitely tastes better with great service. 100%...',5)
   ("I don't have a photo but their al pastor tacos were so good. I was so happy!! Even though we came towards the end of the night, there was not a lot of meat...",4),
   ('They catered an event I went to last night. Roughly 100-200 people. Impressive service, setup, and customer care. Patient to explain various taco options to...',5)]}`


**`get_all_by_cat(api_key, location,categories='restaurants',save_json=True):`**

Eg: **get_all_by_cat(api_key,"San Diego")** scrapes 900 restaurants with their basic information in San Diego

This function outputs a **list** of dictionaries like **search_nearby_restaurants**, but the result is not filtered.


**`get_reviews(api_key, business_id)`** outputs top 3 reviews of a business

eg: **get_reviews(api_key,"YLCrLRRDiec35o2FmBxipA")**

The output is a list of **tuples**, each tuple has index 0 the review and index 1 the rating of the review.













