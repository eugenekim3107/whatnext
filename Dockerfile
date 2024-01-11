# Build the Swift project
FROM swift:latest as swift-builder
WORKDIR /app
COPY ./frontend /app
RUN swift build

# Set up the Python environment for FastAPI
FROM python:3.9
WORKDIR /app

# Copy the SwiftUI files
COPY --from=swift-builder /app /app/frontend

# Copy the FastAPI files
COPY ./backend /app/backend

# Install Python dependencies
RUN pip install --no-cache-dir -r /app/backend/requirements.txt

# Expose the port FastAPI will run on
EXPOSE 8000

# Define the command to run the FastAPI app
CMD ["uvicorn", "backend.main:app", "--host", "0.0.0.0", "--port", "8000"]

