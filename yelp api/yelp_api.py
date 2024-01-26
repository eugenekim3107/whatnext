import requests

# from serpapi import GoogleSearch

#get basic information of all bussiness by categories (900 in total)
def get_all_by_cat(api_key, location,categories='restaurants',save_json=True):
    import json
    url = 'https://api.yelp.com/v3/businesses/search'
    headers = {'Authorization': f'Bearer {api_key}'}
    limit = 50  # Maximum limit as per Yelp's API
    offset = 0
    params = {'location': location, 'categories': categories, 'limit': limit, 'offset': offset}
    response = requests.get(url, headers=headers, params=params)
    data = response.json()
    res = []
    total = data['total']
    if total>=1000:
        total = 900
    offset+=limit
    while total is None or offset < total:
        params = {'location': location, 'categories': categories, 'limit': limit, 'offset': offset}
        response = requests.get(url, headers=headers, params=params)
        data = response.json()
        res.extend(data['businesses'])
        offset += limit
    if save_json:
        json_result = json.dumps(res, indent=4)
        with open("general_info.json", "w") as outfile:
            outfile.write(json_result) 
    return res


def search_business_details(api_key,business_id):
    headers = {'Authorization': f'Bearer {api_key}'}
    url = f'https://api.yelp.com/v3/businesses/{business_id}'
    
    response = requests.get(url, headers=headers)
    return response.json()


# search nearby restaurants by geo location,sorted by rating, and only return places are currently open



def search_nearby(api_key, latitude, longitude, categories='restaurants',radius=20000,cur_open=True,sort_by="rating",include_reviews=True,limit=10):
    headers = {'Authorization': f'Bearer {api_key}'}
    url = 'https://api.yelp.com/v3/businesses/search'
    params = {'latitude': latitude, 'longitude': -1*longitude,"categories": categories,"radius":radius,"limit":limit,'open_now':cur_open,"sort_by":sort_by}

    response = requests.get(url, headers=headers, params=params)
    data = response.json()
    if include_reviews:
        res = [{"rating":d["rating"] if "rating" in d else None,
               "id":d["id"] if "id" in d else None,
               "image":d['image_url'] if 'image_url' in d else None,
                "review_count":d["review_count"] if "review_count" in d else None,
                "name":d["name"] if "name" in d else None,
                "latitude":d["coordinates"]['latitude'] if "coordinates" in d and 'latitude' in d["coordinates"] else None,
                "longitude":d["coordinates"]['longitude'] if "coordinates" in d and 'longitude' in d["coordinates"] else None,
                "transactions":d['transactions'] if "transactions" in d else None,
                "tag":[alias["alias"] for alias in d['categories']],
                "contact":d["phone"] if "contact" in d else None,
                "distance":d["distance"] if "distance" in d else None,
                "price":str(d["price"]) if "price" in d else None,
                "display_address":' ,'.join(d['location']['display_address']) if "location" in d and "display_address" in d['location'] else None,
                "reviews":get_reviews(api_key,d["id"])} for d in data['businesses']]
    else:
        res = [{"rating":d["rating"] if "rating" in d else None,
               "id":d["id"] if "id" in d else None,
               "image":d['image_url'] if 'image_url' in d else None,
                "review_count":d["review_count"] if "review_count" in d else None,
                "name":d["name"] if "name" in d else None,
                "latitude":d["coordinates"]['latitude'] if "coordinates" in d and 'latitude' in d["coordinates"] else None,
                "longitude":d["coordinates"]['longitude'] if "coordinates" in d and 'longitude' in d["coordinates"] else None,
                "transactions":d['transactions'] if "transactions" in d else None,
                "tag":[alias["alias"] for alias in d['categories']],
                "contact":d["phone"] if "contact" in d else None,
                "distance":d["distance"] if "distance" in d else None,
                "price":str(d["price"]) if "price" in d else None,
                "display_address":' ,'.join(d['location']['display_address']) if "location" in d and "display_address" in d['location'] else None} for d in data['businesses']]

    return res






def get_reviews(api_key, business_id):
    headers = {'Authorization': f'Bearer {api_key}'}
    url = f'https://api.yelp.com/v3/businesses/{business_id}/reviews'
    
    response = requests.get(url, headers=headers)
    data = response.json()
    res = [r["text"] for r in data["reviews"]]
    return res


#utilize serpapi (third party api) to retreieve top 50 reviews for a business

# def get_newest_reviews_by_id(api_key, business_id,numbers_reviews=50,save_json=True):
#     start = 0
#     import json
#     res = []
#     while start <numbers_reviews :
#         params = {"engine": "yelp_reviews","place_id": business_id,"api_key": api_key,"start":start,"sortby":"date_desc"}
#         search = GoogleSearch(params)
#         reviews = search.get_dict()['reviews']
#         bussiness_name = search.get_dict()['search_information']['business']
#         res.extend(reviews)
#         start+=10
#     result = {"name":bussiness_name,"id":business_id,"reviews":res}
#     if save_json:
#         json_result = json.dumps(result, indent=4)
#         with open("reviews_by_bussiness.json", "a") as outfile:
#             outfile.write(json_result) 
#             outfile.write("\n") 
#     return result


# check how many api calls are remained today
def check_api_calls_left(api_key):
    url = 'https://api.yelp.com/v3/businesses/search'
    headers = {'Authorization': f'Bearer {api_key}'}
    params = {'location': "San Diego", 'categories':'restaurants', 'limit':50, 'offset': 850}
    response = requests.get(url, headers=headers, params=params)
    return response.headers['ratelimit-remaining']