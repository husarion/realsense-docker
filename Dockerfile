FROM ros:noetic-ros-core

SHELL ["/bin/bash", "-c"]

RUN apt-get update  && \
    apt-get install -y \
        ros-$ROS_DISTRO-rgbd-launch\
        ros-$ROS_DISTRO-realsense2-camera && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
