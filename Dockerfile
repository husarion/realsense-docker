ARG ROS_DISTRO=humble
ARG PREFIX=

FROM husarnet/ros:${PREFIX}${ROS_DISTRO}-ros-core

SHELL ["/bin/bash", "-c"]

RUN apt-get update  && \
    apt-get install -y \
        ros-$ROS_DISTRO-realsense2-camera ros-$ROS_DISTRO-image-transport-plugins && \
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*
