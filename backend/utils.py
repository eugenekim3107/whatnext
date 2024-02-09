from datetime import timedelta
import uuid

def generate_sort_assistant_id(openai_client):
    instructions = "Rank the locations from our chat history and return a comma-separated list of their business IDs in order of preference. Format the response as: 'business_id1, business_id2, ...'. Provide only this list, without additional text or explanation."
    assistant = openai_client.beta.assistants.create(
        instructions=instructions,
        model="gpt-4-0125-preview"
    )
    return assistant.id

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

# Generate new assistant id
def generate_assistant_id(openai_client):
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
    instructions = "As the WhatNext? app's assistant, your role is to offer personalized suggestions for places to visit, dine, or activities to enjoy, based on user preferences. Follow these steps to assist users effectively:\n1.Identify requests for suggestions in user messages, looking for keywords like 'looking for', 'suggest', or mentions of specific places or activities.\n2.Upon recognizing a suggestion request, use fetch_nearby_locations with optional parameters like limit, radius, categories, and cur_open to find suitable recommendations. Avoid asking for user location.\n3.Present a curated list of recommendations, detailing names, locations, and why they're a good match for the user's interests.\n4.Encourage further inquiries or preference refinements for even more personalized suggestions. Focus on helping users discover new experiences that align with their interests, utilizing available tools for a responsive and customized service."
    assistant = openai_client.beta.assistants.create(
        instructions=instructions,
        model="gpt-4-0125-preview",
        tools=tools
    )
    return assistant.id

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

