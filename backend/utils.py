from datetime import timedelta
import uuid
import json

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

# Generate new session id
def generate_unique_session_id():
    return str(uuid.uuid4())

# Generate new thread id
def generate_thread_id(openai_client):
    thread = openai_client.beta.threads.create()
    return thread.id

def open_json_file(file_path):
    with open(file_path, 'r') as file:
        file_content = json.load(file)
    return file_content

# Generate new assistant id
def generate_assistant_id(openai_client):
    valid_limit = [3, 50, 10]
    valid_radius = [1000, 100000, 10000]
    valid_cur_open = [0, 1, 1]
    categories_file_path = "categories.json"
    tags_file_path = "tags.json"
    valid_categories = open_json_file(categories_file_path)
    valid_tags = open_json_file(tags_file_path)
    valid_sort_by = ["review_count", "stars", "random"]
    tools = [
        {
            "type": "function",
            "function": {
                "name": "fetch_nearby_locations_condensed",
                "description": "Retrieve the locations of potential places for users to visit (DO NOT NEED USERS LOCATION)",
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
                            "enum": valid_categories,
                            "description": f"Primary categories to filter the search, representing broad sectors or types of locations. Categories help in segmenting locations into major groups for easier discovery. Categories must be in 'enum'."
                        },
                        "cur_open": {
                            "type": "string",
                            "enum": [0, 1],
                            "description": f"Filter based on current open status. 0 for both closed and open, while 1 is just for open. Default: {valid_cur_open[2]}."
                        },
                        "tag": {
                            "type": "string",
                            "enum": valid_tags,
                            "description": f"Optional tags to refine your search based on specific attributes or specialties within a category. Tags provide a granular level of filtering to help you find locations that offer particular services, cuisines, or features. Tags must be in 'enum'."
                        },
                        "sort_by": {
                            "type": "string",
                            "enum": valid_sort_by,
                            "description": f"Sorts the results by the specified criteria. Options: {', '.join(valid_sort_by[:-1])}, or {valid_sort_by[-1]}."
                        }
                    },
                    "required": ["categories"],
                },
            },
        },
        {
            "type": "function",
            "function": {
                "name": "fetch_specific_location",
                "description": "Input a business_id and retrieve its detailed information (ONLY FOR SPECIFIC BUSINESS_ID QUERY).",
                "parameters": {
                    "type": "object",
                    "properties": {
                        "business_id": {
                            "type": "string",
                            "description": f"The business_id used to identify a specifc location. The business_id is composed of the category and a four-digit number."
                        }
                    },
                    "required": ["business_id"],
                }
            }
        }
    ]
    instructions = (
        "As the WhatNext? app's location recommender, your role is to offer personalized suggestions for places "
        "to visit, dine, or activities to enjoy, based on user preferences. Do not answer unrelated questions. "
        "\nFollow these steps to assist users effectively:\n1. Identify requests for suggestions in user " 
        "messages, looking for keywords like 'looking for', 'suggest', or mentions of specific places or activities. "
        "When the user prompts are too broad, interact with the user for more tailored recommendations.\n2. Upon recognizing a suggestion request, "
        "analyze the user preference from the conversion and trigger fetch_nearby_locations to find suitable recommendations. "
        "Avoid asking for user location. If fetch_nearby_locations returns an empty string, tell "
        "the user there are currently no open, nearby, or specified locations. If the user asks for information "
        "about a specific location by providing the location's name, extract the corresponding business_id and trigger fetch_specific_location."
        "Use this information in your response to the user."
    )
    assistant = openai_client.beta.assistants.create(
        instructions=instructions,
        name="WhatNext? Location Recommender",
        # model="gpt-3.5-turbo-0125",
        model="gpt-4-0125-preview",
        tools=tools
    )
    return assistant.id

# Create sorting run
def create_sorting_run(openai_client, thread_id, assistant_id):
    instructions = (
            "As the WhatNext? app's location sorter, review the prior conversation history and user bio for details on user preference. "
            "Identify and rank, from highest to lowest ranked, the locations that best match the user's preference. "
            "Your response should be a comma-separated list of business_id associated with these locations, "
            "with a single space after each comma, and no spaces before the IDs or additional characters. "
            "The format must be exactly as follows: 'business_id1, business_id2, business_id3, ...'. "
            "Ensure the output adheres strictly to this structure, without any prefixes, bullet points, explanation, and additional text."
        )
    
    run_sort = openai_client.beta.threads.runs.create(
        thread_id=thread_id,
        assistant_id=assistant_id,
        instructions=instructions,
        tools=[],
        # model="gpt-3.5-turbo-0125",
        model="gpt-4-0125-preview"
    )
    return run_sort.id

# Retrieves thread_id and assistant_id based on session_id
def retrieve_chat_info(session_id, redis_client, openai_client):
    if session_id is None or not redis_client.exists(session_id):
        session_id = generate_unique_session_id()
        thread_id = generate_thread_id(openai_client)
        assistant_id = generate_assistant_id(openai_client)
        redis_client.hset(session_id, mapping={"thread_id": thread_id, "assistant_id": assistant_id})
    values = redis_client.hgetall(session_id)
    thread_id = values.get("thread_id")
    assistant_id = values.get("assistant_id")
    return session_id, thread_id, assistant_id

# Retrieves user preference
def retrieve_user_preference(user_id, redis_client):
    user_preference = redis_client.lrange(user_id, 0, -1)
    return user_preference

# Updates user preference
def update_user_preference(user_id, new_preferences, redis_client):
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