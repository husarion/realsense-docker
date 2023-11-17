ARG ROS_DISTRO=humble
ARG PREFIX=

FROM husarnet/ros:${PREFIX}${ROS_DISTRO}-ros-base

SHELL ["/bin/bash", "-c"]

RUN apt-get update && \
    apt-get install -y \
        ros-$ROS_DISTRO-realsense2-camera &&\
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Create health check package
WORKDIR /ros2_ws

RUN mkdir src && cd src/ && \
    source /opt/ros/$ROS_DISTRO/setup.bash && \
    ros2 pkg create healthcheck_pkg --build-type ament_cmake --dependencies rclcpp std_msgs && \
    sed -i '/find_package(std_msgs REQUIRED)/a \
            find_package(sensor_msgs REQUIRED)\n \
            add_executable(healthcheck_node src/healthcheck.cpp)\n \
            ament_target_dependencies(healthcheck_node rclcpp std_msgs sensor_msgs)\n \
            install(TARGETS healthcheck_node DESTINATION lib/${PROJECT_NAME})' \
            /ros2_ws/src/healthcheck_pkg/CMakeLists.txt

COPY ./healthcheck.cpp /ros2_ws/src/healthcheck_pkg/src/

RUN source /opt/ros/$ROS_DISTRO/setup.bash && \
    colcon build

COPY ./ros_entrypoint.sh /

COPY ./healthcheck.sh /
HEALTHCHECK --interval=7s --timeout=2s  --start-period=5s --retries=5 \
    CMD ["/healthcheck.sh"]

RUN echo $(cat /opt/ros/humble/share/realsense2_camera/package.xml | grep '<version>' | sed -r 's/.*<version>([0-9]+.[0-9]+.[0-9]+)<\/version>/\1/g') > /version.txt
