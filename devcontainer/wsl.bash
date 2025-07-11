#!/bin/bash

# Variables
IMAGE_NAME="ros2-devimage"
CONTAINER_NAME="ros2-devcontainer"
USER="willy"
WORKSPACE_HOST="$(pwd)/.."  # Local project dir
WORKSPACE_CONTAINER="/home/$USER/Willy2.0"

docker container rm -f "$CONTAINER_NAME" || true

# Build Docker image
docker build -t "$IMAGE_NAME" -f "$1" .

# Step 2: Run the container with GPU and X11/WSLg support
echo "Running container..."
sudo docker run -it --rm\
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
