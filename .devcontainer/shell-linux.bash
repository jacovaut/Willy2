#!/bin/bash
set -e

# Variables
IMAGE_NAME="ros2-devcontainer"
CONTAINER_NAME="ros2-devcontainer-container"
USER="willy"
WORKSPACE_HOST="$(pwd)/.."  # Local project dir
WORKSPACE_CONTAINER="/home/$USER/Willy2.0"

# For X11 GUI forwarding
XSOCK="/tmp/.X11-unix"
XAUTH="/tmp/.docker.xauth"

# Create Xauthority file if needed
if [ ! -f "$XAUTH" ]; then
    touch "$XAUTH"
    xauth_list=$(xauth nlist "$DISPLAY")
    if [ -n "$xauth_list" ]; then
        echo "$xauth_list" | sed -e 's/^..../ffff/' | xauth -f "$XAUTH" nmerge -
    fi
fi

# Allow local connections (may be unsafe on shared systems)
xhost +local:docker

# Build Docker image
docker build -t "$IMAGE_NAME" .

# Run container with X11 support
docker run -it --rm \
  --name "$CONTAINER_NAME" \
  --net=host \
  --ipc=host \
  --pid=host \
  -e DISPLAY="$DISPLAY" \
  -e XDG_RUNTIME_DIR=/run/user/1000 \
  -e XAUTHORITY="$XAUTH" \
  -e ROS_DOMAIN_ID=42 \
  -e ROS_AUTOMATIC_DISCOVERY_RANGE=LOCALHOST \
  -e TERM=xterm-256color \
  -v /run/user/1000:/run/user/1000 \
  -v "$WORKSPACE_HOST":"$WORKSPACE_CONTAINER" \
  -v "$XSOCK":"$XSOCK" \
  -v "$XAUTH":"$XAUTH" \
  --user "$USER" \
  "$IMAGE_NAME" \
  bash -c "\
    echo 'source /opt/ros/humble/setup.bash' >> /home/$USER/.bashrc && \
    echo 'source $WORKSPACE_CONTAINER/ws/install/setup.bash' >> /home/$USER/.bashrc && \
    sudo apt update && \
    exec bash
  "

# Revoke X11 permissions
xhost -local:docker