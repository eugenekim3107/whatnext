# Backend Server Setup Instructions

## Initializing EC2 Instance
- **Start EC2 Instance:**
  1. Log in to AWS using UCSD portal.
  2. Launch an EC2 instance named `WhatNextInstance`.
  3. Note down the Elastic IP address of the instance for later use.

## Local Development and Testing
To develop and test locally while connecting to MongoDB hosted on the EC2 instance, follow these steps:

### SSH Port Forwarding
Set up SSH port forwarding to connect to MongoDB on the EC2 instance:
1. Secure the SSH key:
```
chmod 400 whatnext/backend/WhatNextAdminKey.pem
```
2. Establish an SSH tunnel for MongoDB access:
```
ssh -i whatnext/backend/WhatNextAdminKey.pem -L 8000:localhost:27017 ubuntu@<Elastic-IP>
```
- `8000`: Local port on your machine.
- `localhost:27017`: Remote destination (MongoDB port on EC2 instance).
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
curl -X 'GET' 'http://localhost:8080/nearby_locations' -H 'accept: application/json' -H 'whatnext_token: whatnext'
```

## Production
For setting up your environment for production, follow these steps:

### SSH Port Forwarding
Repeat the steps for SSH port forwarding as in the local development and testing section to connect to MongoDB on the EC2 instance.

### Running Docker Container
Ensure MongoDB is running on the EC2 instance. It should run automatically upon initialization. To check the status of MongoDB:
```
systemctl status mongod
```
To run the Docker container:
```
docker run -p 80:8000 whatnext-image:latest
```
- `80`: Port to accept HTTP requests.
- `8000`: Specifies the port for the FastAPI server.
- `whatnext-image:latest`: The Docker image name.

### Testing Endpoints
To test an endpoint in production, use the following command:
```
curl -X 'GET' 'http://<Elastic-IP>/nearby_locations' -H 'accept: application/json' -H 'whatnext_token: whatnext'
```
Replace `Elastic-IP` with the actual Elastic IP address of your EC2 instance.
