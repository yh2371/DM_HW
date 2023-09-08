## Docker Build Instructions

- docker build -t deepmimic:latest .
- xhost +local:docker
- docker run -it -e DISPLAY=$DISPLAY -v /tmp/.X11-unix:/tmp/.X11-unix -v/dev/dri:/dev/dri deepmimic:latest /bin/bash