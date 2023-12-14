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
    ros2 pkg create healthcheck_pkg --build-type ament_cmake --dependencies rclcpp sensor_msgs && \
    sed -i '/find_package(sensor_msgs REQUIRED)/a \
            add_executable(healthcheck_node src/healthcheck.cpp)\n \
            ament_target_dependencies(healthcheck_node rclcpp sensor_msgs)\n \
            install(TARGETS healthcheck_node DESTINATION lib/${PROJECT_NAME})' \
            /ros2_ws/src/healthcheck_pkg/CMakeLists.txt

COPY ./healthcheck.cpp /ros2_ws/src/healthcheck_pkg/src/

RUN source /opt/ros/$ROS_DISTRO/setup.bash && \
    colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release && \
    # Save version
    echo $(cat /opt/ros/humble/share/realsense2_camera/package.xml | grep '<version>' | sed -r 's/.*<version>([0-9]+.[0-9]+.[0-9]+)<\/version>/\1/g') > /version.txt && \
    # Size optimalization
    rm -rf build log src

# Run healthcheck in background
RUN if [ -f "/ros_entrypoint.sh" ]; then \
        sed -i '/test -f "\/ros2_ws\/install\/setup.bash" && source "\/ros2_ws\/install\/setup.bash"/a \
        ros2 run healthcheck_pkg healthcheck_node &' \
        /ros_entrypoint.sh; \
    else \
        sed -i '/test -f "\/ros2_ws\/install\/setup.bash" && source "\/ros2_ws\/install\/setup.bash"/a \
        ros2 run healthcheck_pkg healthcheck_node &' \
        /vulcanexus_entrypoint.sh; \
    fi

COPY ./healthcheck.sh /
HEALTHCHECK --interval=2s --timeout=1s --start-period=20s --retries=1 \
    CMD ["/healthcheck.sh"]

