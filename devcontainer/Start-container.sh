#!/bin/bash

if ! sudo -n true 2>/dev/null; then
    echo "Error: Must use sudo"
    exit 1
fi

echo "What container would you like to start? please type 1, 2, or 3"
echo "1 : Gazebo_robot (for simulating Willy)"
echo "2 : Robot_container (for running code on the real Willy)"
echo "3 : Remote (for acces to tools like teleop_twist_keybaord, rqt and rviz2)"

read -r response
case "$response" in
    1)
        DOCKERFILE="Dockerfile_gazebo"
        STR="gazebo"
        ;;
    2)
        DOCKERFILE="Dockerfile_robot"
        STR="robot"
        ;;
    3)
        DOCKERFILE="Dockerfile_remote"
        STR="remote"
        ;;
    *)
        echo "invalid response"
        exit 1
        ;;
esac

echo "Are you running in WSL or native Linux? (type wsl or linux)"

read -r response

case "$response" in
    wsl|WSL)
        echo "you are running WSL with Dockerfile : $DOCKERFILE"
        chmod +x ./wsl.bash
        ./wsl.bash "$DOCKERFILE" "$STR"
        ;;
    linux|Linux)
        echo "you are running native Linux with Dockerfile : $DOCKERFILE"
        chmod +x ./linux.bash
        ./linux.bash "$DOCKERFILE" "$STR"
        ;;
    *)
        echo "invalid response"
        exit 1
        ;;
esac

