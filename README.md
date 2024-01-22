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

### Accessing the SwiftUI Project on XCode
1. **Navigate to the Frontend Directory**
   - Change into the frontend directory:
    ```
    cd whatnext/frontend
    ```
2. **Open Folder on XCode**
   - Open the Folder 'whatnext' on XCode
  