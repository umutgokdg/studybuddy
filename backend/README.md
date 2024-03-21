# blg411e
BLG411E Project - StudyBuddy

# Backend Server Setup Instructions

This guide will walk you through the steps to set up and run the backend server using Docker.

## Prerequisites

- Ensure that you have Docker installed on your system. If you do not have Docker installed, you can download and install it from [Docker's official website](https://www.docker.com/get-started).

## Steps to Run the Server

1. **Clone the Repository**
   - First, clone the repository to your local machine and change into the directory of the repo:
     ```
     git clone git@github.com:silakucuknane/blg411e.git
     cd blg411e/
     ```

2. **Build the Docker Image**
   - Build the Docker image using the provided Dockerfile. This step creates an image with the necessary environment for your backend server:
     ```
     sudo docker build -t backend_server .
     ```

3. **Run the Container**
   - Once the image is built, you can run the container. The following command mounts your current directory into the container and starts the server:
     ```
     cd backend/
     sudo docker run --rm -p 3500:3500 -d -v $(pwd):/usr/src/app --name backend backend_server
     ```
4. **Ensure server is running**
   - Ensure the server is running by typing:
   ```
   sudo docker ps
   ```

## Stopping the Server

- To stop the backend server, you can stop the running container:
     ```
     sudo docker container stop backend
     ```

by
Sıla Küçüknane
Esat Yusuf Gündoğdu
Osman Barış Türker
Mehmet Umut Gökdağ
Ulaş Sezgin
