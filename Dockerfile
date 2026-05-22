ARG ROS_DISTRO=jazzy
ARG PREFIX=

FROM husarnet/ros:${PREFIX}${ROS_DISTRO}-ros-core

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get install -y \
        ros-$ROS_DISTRO-realsense2-camera \
        ros-$ROS_DISTRO-compressed-image-transport \
        &&\
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

RUN echo $(cat /opt/ros/$ROS_DISTRO/share/realsense2_camera/package.xml | grep '<version>' | sed -r 's/.*<version>([0-9]+.[0-9]+.[0-9]+)<\/version>/\1/g') > /version.txt
