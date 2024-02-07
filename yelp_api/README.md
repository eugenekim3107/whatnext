### Yelp API
**general_info.json** is the scraped basic information restaurants in San Diego, you can use their business id to test functions.



Below is my yelp API, you can register a yelp api account and use yours.
`api_key = "sMFOsH94cd7UX9DqgoU56plsTC9C4MWkaigY9r4yQMELhtCAwbRzYgDLymy9qreZl6YXWyXo5lznGIWmCi7xTFr1BG3JJx5nYT70WEjPuveXBqKbrTFU5ROVk82mZXYx"`

Eugene's API:
`api_key = "zVgczAZq-sRyRhKzSJ34uziLaLdgyVBSopgBfynGHKf52T2zGJG-Z9BVXFXOG5w-8RVHoziIL9RY1nLr_DqjfqE9UwpCN6Jp4Ze5BVzEDEm1vcaBQ25mBlCeSZO5ZXYx"`


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

  
