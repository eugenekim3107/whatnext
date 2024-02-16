import json

def open_json_file(file_path):
    with open(file_path, 'r') as file:
        file_content = json.load(file)
    return file_content

def write_json_file(file_path, data):
    with open(file_path, 'w') as file:
        json.dump(data, file, indent=4)

def main():
    file_content = open_json_file("yelp_api/sample_2.json")
    counter = 1001
    for document in file_content:
        category_prefix = document['categories'].split(',')[0][:3].lower()
        new_business_id = f"{category_prefix}{counter}"
        counter += 1
        
        document["business_id"] = new_business_id
    
    write_json_file("yelp_api/updated_sample.json", file_content)
    

if __name__ == "__main__":
    main()