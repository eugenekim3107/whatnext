# Backend Server Setup Instructions

## Initializing EC2 Instance
- **Start EC2 Instance:**
  1. Log in to AWS using UCSD portal.
  2. Launch an EC2 instance named `WhatNextInstance`.
  3. Note down the Elastic IP address of the instance for later use.

## Local Development and Testing
To develop and test locally while connecting to MongoDB hosted on the EC2 instance, follow these steps:

### MongoDB SSH Port Forwarding

Set up SSH port forwarding to connect to MongoDB on the EC2 instance:
1. Secure the SSH key:
```
chmod 400 whatnext/backend/WhatNextAdminKey.pem
```
2. Establish an SSH tunnel for MongoDB access:
```
ssh -i whatnext/backend/WhatNextAdminKey.pem -L 8000:localhost:27017 ubuntu@<Elastic-IP>
```
- `8000`: Local port on your machine for MongoDB.
- `localhost:27017`: Remote destination (MongoDB port on EC2 instance).
- `Elastic-IP`: Replace with the actual Elastic IP address of your EC2 instance.

### Redis-server SSH Port Forwarding

Set up SSH port forwarding to connect to Redis-server on the EC2 instance:
1. Secure the SSH key:
```
chmod 400 whatnext/backend/WhatNextAdminKey.pem
```
2. Establish an SSH tunnel for Redis-server access:
```
ssh -i whatnext/backend/WhatNextAdminKey.pem -L 8001:localhost:6379 ubuntu@<Elastic-IP>
```
- `8001`: Local port on your machine for Redis-server.
- `localhost:6379`: Remote destination (Redis-server port on EC2 instance).
- `Elastic-IP`: Replace with the actual Elastic IP address of your EC2 instance.

### Running FastAPI Server
To start the FastAPI server locally:
```
uvicorn main:app --host 0.0.0.0 --port 8080 --reload
```
- `0.0.0.0`: Binds the server to all IP addresses.
- `8080`: Specifies the port for the FastAPI server.
- `--reload`: Enables auto-reload on file changes for development.
- Ensure the packages in requirements.txt are correctly installed in your environment.

### Testing Endpoints
To test an endpoint, use the following command:
```
curl -X 'GET' 'http://localhost:8080/api/nearby_locations' -H 'accept: application/json' -H 'whatnext_token: whatnext'
```

```
curl -X POST "http://localhost:8080/api/chatgpt_response" -H "Content-Type: application/json" -H "whatnext_token: whatnext" -d '{"user_id": "eugenekim", "message": "I would like to drink some coffee", "latitude": 32.8723812680163, "longitude": -117.21242234341588}'
```

## Production
For setting up your environment for production, follow these steps:

### SSH Port Forwarding
Repeat the steps for SSH port forwarding as in the local development and testing section to connect to MongoDB on the EC2 instance.

### Running Docker Container and Databases
Ensure MongoDB is running on the EC2 instance. It should run automatically upon initialization. To check the status of MongoDB:
```
systemctl status mongod
```
If MongoDB is not running, initialize the database using:
```
sudo systemctl start mongod
sudo systemctl enable mongod
```

Ensure Redis-server is running on the EC2 instance. It should run automatically upon initalization. To check the status of the Redis-server:
```
systemctl status redis-server.service
```
If Redis-server is not running, initalize the database using:
```
sudo systemctl start redis-server.service
sudo systemctl enable redis-server.service
```

Ensure the Docker container is running on the EC2 instance. It should run automatically upon initialization. To check the status of the Docker container:
```
docker ps
```
If the Docker conatiner is not running, initialize the database using:
```
docker run -d --restart=always --name whatnext-container -p 8000:8000 --env OPENAI_API_KEY=$OPENAI_API_KEY --env whatnext_token=$whatnext_token whatnext-image
```
- `whatnext-container`: The name of the container.
- `whatnext-image`: The name of the image.

### Testing Endpoints
To test an endpoint in production, use the following command:
```
curl -k -H "whatnext_token: whatnext" "https://whatnext.live/api/nearby_locations"
```
```
curl -k -X POST "https://whatnext.live/api/chatgpt_response" -H "Content-Type: application/json" -H "whatnext_token: whatnext" -d '{"user_id": "eugenekim", "message": "I want to go hiking. Can you give me some suggestions?", "latitude": 32.8723812680163, "longitude": -117.21242234341588}'
```

## Important Notes

**Official Website**: [whatnext.live](https://whatnext.live)

### Website and API Integration

[whatnext.live](https://whatnext.live) is designed to fulfill dual roles:

1. **Web Hosting (Frontend)**: Serving as the primary access point for users to interact with our platform. The front-end is built with user experience in mind, offering intuitive navigation and responsive design.

2. **API Endpoint (Backend)**: Powering the back-end services, WhatNext.live also acts as the gateway for API access, handling data requests and responses that drive the platform's functionality.

### API Usage Guidelines

To ensure clarity and maintain a structured approach to API interactions, all API endpoints adhere to a specific path convention:

**Endpoint Prefix**: All API endpoints begin with `/api/`. This prefix is crucial for routing requests to the appropriate back-end services.
Examples of API Endpoint Structures:
- **GET Requests**: To retrieve data from our platform, you'll use the GET method with endpoints structured as follows:
```
https://whatnext.live/api/[endpoint-name]
```
- **POST Requests**: For submitting data to our platform, POST requests follow a similar structure:

```
https://whatnext.live/api/[endpoint-name]
```
By adhering to these guidelines, we ensure that API requests are efficiently processed and correctly directed to the back-end services, facilitating a robust and reliable platform for all users.