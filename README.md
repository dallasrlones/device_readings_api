
# Device Readings API

## Introduction

This project implements a web API that receives and processes device readings. It allows devices to send their readings to the server, and provides endpoints for clients to retrieve the latest reading's timestamp and the cumulative count of all readings for a specific device. All data is stored in-memory and not persisted to disk.

----------

## Instructions to Build and Start the Web API Locally

### Prerequisites

-   **Docker**
-   **Docker Compose**

### Steps

1.  **Clone the Repository**
    
    ```bash
        git clone <repository-url>
        cd <repository-directory>
    ``` 
    
2.  **Build the Docker Image**
    
    ```bash
        docker-compose build
    ```
    
3.  **Start the Application**
    
    ```bash
        docker-compose run app
    ``` 
    
    The API server will start and listen on `http://localhost:3000`.
    
4.  **Run the Test Suite**
    
    To run the tests, execute:
    
    ```bash
        docker-compose run test
    ``` 
    
    This will run the `rspec` tests defined in the `spec` directory.
    

----------

## API Documentation

### **1. Store Readings**

-   **Endpoint:** 
    `POST /devices/readings` 
    
-   **Description:**
    
    Stores readings for a device. Readings can be sent out of order, and duplicate readings (same timestamp) are ignored.
    
-   **Request Body Parameters:**
    
    -   `id` (string, required): The UUID of the device.
        
    -   `readings` (array of objects, required): The readings to store.
        
        Each reading object must contain:
        
        -   `timestamp` (string, required): An ISO-8601 timestamp of when the reading was taken.
        -   `count` (integer, required): The reading data.
-   **Sample Request Body:**
    
    ```JSON
    {
        "id": "36d5658a-6908-479e-887e-a949ec199272",
        "readings": [
            {
                "timestamp": "2021-09-29T16:08:15+01:00",
                "count": 2
            },
            {
                "timestamp": "2021-09-29T16:09:15+01:00",
                "count": 15
            }
        ]
    }
    ```
    
-   **Responses:**
    
    -   `200 OK`: Readings were successfully stored.
    -   `400 Bad Request`: Missing device ID or required parameters.
    -   `422 Unprocessable Entity`: Invalid readings format.

----------

### **2. Fetch Latest Reading's Timestamp**

-   **Endpoint:**
    `GET /devices/:id/latest_timestamp` 
    
-   **Description:**
    
    Retrieves the timestamp of the latest reading for the specified device.
    
-   **Path Parameters:**
    
    -   `id` (string, required): The UUID of the device.
-   **Responses:**
    
    -   `200 OK`: Returns the latest timestamp.
        
        ```JSON
        {
            "latest_timestamp": "2021-09-29T16:09:15+01:00"
        }
        ```
        
    -   `404 Not Found`: No readings found for the specified device.
        

----------

### **3. Fetch Cumulative Count**

-   **Endpoint:**
    `GET /devices/:id/cumulative_count` 
    
-   **Description:**
    
    Retrieves the cumulative count of all readings for the specified device.
    
-   **Path Parameters:**
    
    -   `id` (string, required): The UUID of the device.
-   **Responses:**
    
    -   `200 OK`: Returns the cumulative count.
        
        ```JSON
        {
            "cumulative_count": 17
        }
        ```
        

----------

## Project Structure

-   **`app/controllers/devices_controller.rb`**:
    
    Contains the `DevicesController` which handles incoming requests related to device readings. It includes actions to store readings and retrieve the latest timestamp and cumulative count for a device.
    
-   **`app/models/device_store.rb`**:
    
    Implements the `DeviceStore` singleton class, which manages the in-memory storage of device readings. It uses `Concurrent::Map` for thread-safe operations.
    
-   **`config/routes.rb`**:
    
    Defines the API routes for handling device readings, latest timestamp retrieval, and cumulative count retrieval.
    
-   **`spec/requests/devices_spec.rb`**:
    
    Contains request specs for testing the API endpoints, ensuring they behave as expected under various scenarios.
    
-   **`spec/models/device_store_spec.rb`**:
    
    Contains model specs for testing the `DeviceStore` class and its methods.
    
-   **`Dockerfile`**:
    
    Specifies the Docker image configuration for building and running the application.
    
-   **`docker-compose.yml`**:
    
    Defines services for running the application and tests in Docker containers.
    

----------

## Improvements and Optimizations

Given more time, the following enhancements could be made:

-   **Persistent Storage**:
    
    Implement data persistence using a database or external storage solution to retain readings across server restarts. I would do this with Redis because of the ability to hit Redis with multiple instances of this service, Redis it the source of truth.
    
-   **Concurrency Handling**:
    
    Further ensure thread safety and data consistency when handling multiple concurrent requests, possibly by adding locks or using more advanced concurrency primitives. Redis can also help with this.
    
-   **Input Validation**:
    
    Enhance input validation to provide more detailed error messages and handle edge cases, such as invalid UUID formats or counts less than zero.
    
-   **API Authentication**:
    
    Add authentication and authorization mechanisms to secure the API endpoints.
    
-   **Rate Limiting**:
    
    Implement rate limiting to prevent abuse and ensure fair usage among clients.
    
-   **Comprehensive Logging**:
    
    Add structured logging for better observability and easier debugging in production environments.
    
-   **Monitoring and Metrics**:
    
    Integrate monitoring tools to track application performance and health metrics.
    
-   **API Documentation Tools**:
    
    Use tools like Swagger or API Blueprint to generate interactive API documentation.
    
-   **Error Handling Enhancements**:
    
    Create custom error classes and rescue handlers to manage exceptions more gracefully.
    

----------

## Notes

-   **Testing**:
    
    The application includes a comprehensive test suite using RSpec to ensure all functionalities work as expected.
    
-   **No External Dependencies**:
    
    The API is self-contained and does not rely on any external services, making it easy to deploy and run.
    
-   **Stateless API**:
    
    Since data is stored in-memory, the API is stateless between server restarts. Persistent storage is recommended for production use cases.