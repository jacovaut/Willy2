#!/bin/bash

# Define names and paths
IMAGE_NAME="ros2-devcontainer"
DOCKERFILE_PATH="Dockerfile"  # Adjust if your Dockerfile is in a subdirectory
LOCAL_WORKSPACE_PATH="./.."
CONTAINER_WORKSPACE_PATH="/home/willy/Willy2.0"

# Step 1: Build the Docker image
echo "Building Docker image '$IMAGE_NAME' from $DOCKERFILE_PATH..."
docker build -t "$IMAGE_NAME" -f "$DOCKERFILE_PATH" .

if sudo docker ps -a --format '{{.Names}}' | grep "$IMAGE_NAME"; then
    echo "Removing existing container: $IMAGE_NAME"
    sudo docker stop "$IMAGE_NAME" >/dev/null 2>&1
    sudo docker rm "$IMAGE_NAME"
fi

# Step 2: Run the container with GPU and X11/WSLg support
echo "Running container..."
sudo docker run -it \
    --gpus all \
    --net=host \
    --ipc=host \
    --pid=host \
    --device=/dev/dxg \
    -v /tmp/.X11-unix:/tmp/.X11-unix \
    -v /mnt/wslg:/mnt/wslg \
    -v /usr/lib/wsl:/usr/lib/wsl \
    -e DISPLAY=$DISPLAY \
    -e LD_LIBRARY_PATH=/usr/lib/wsl/lib \
    -e TERM=$TERM \
    -v "$LOCAL_WORKSPACE_PATH":"$CONTAINER_WORKSPACE_PATH" \
    --workdir "$CONTAINER_WORKSPACE_PATH" \
    --user "$(id -u):$(id -g)" \
    --name ros2-devcontainer \
    --hostname ros2-dev \
    "$IMAGE_NAME" \
    bash -c " \
        echo 'source /opt/ros/humble/setup.bash' >> /home/willy/.bashrc && \
        echo 'source /home/willy/Willy2.0/ws/install/setup.bash' >> /home/willy/.bashrc && \
        sudo apt update && \
        exec bash"
