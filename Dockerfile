ARG ROS_DISTRO=humble
ARG PREFIX=

## =========================== Healthcheck builder ===============================
FROM husarnet/ros:${PREFIX}${ROS_DISTRO}-ros-base AS healthcheck_builder

ARG ROS_DISTRO
ARG PREFIX

WORKDIR /healthcheck_ws

COPY healthcheck.cpp /

RUN mkdir src && cd src && \
    MYDISTRO=${PREFIX:-ros}; MYDISTRO=${MYDISTRO//-/} && \
    source /opt/$MYDISTRO/$ROS_DISTRO/setup.bash && \
    ros2 pkg create healthcheck_pkg --build-type ament_cmake --dependencies rclcpp sensor_msgs && \
    sed -i '/find_package(sensor_msgs REQUIRED)/a \
            add_executable(healthcheck_node src/healthcheck.cpp)\n \
            ament_target_dependencies(healthcheck_node rclcpp sensor_msgs)\n \
            install(TARGETS healthcheck_node DESTINATION lib/${PROJECT_NAME})' \
            /healthcheck_ws/src/healthcheck_pkg/CMakeLists.txt && \
    mv /healthcheck.cpp /healthcheck_ws/src/healthcheck_pkg/src/ && \
    cd .. && \
    colcon build --cmake-args -DCMAKE_BUILD_TYPE=Release

## =========================== Final Stage ===============================
FROM husarnet/ros:${PREFIX}${ROS_DISTRO}-ros-core AS final_stage

WORKDIR /ros2_ws

COPY --from=healthcheck_builder /healthcheck_ws/install /healthcheck_ws/install

RUN apt-get update && \
    apt-get install -y \
        ros-$ROS_DISTRO-realsense2-camera &&\
    apt-get autoremove -y && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Save version
RUN echo $(cat /opt/ros/humble/share/realsense2_camera/package.xml | grep '<version>' | sed -r 's/.*<version>([0-9]+.[0-9]+.[0-9]+)<\/version>/\1/g') > /version.txt

# Run healthcheck in background
RUN entrypoint_file=$(if [ -f "/ros_entrypoint.sh" ]; then echo "/ros_entrypoint.sh"; else echo "/vulcanexus_entrypoint.sh"; fi) && \
    sed -i '/test -f "\/ros2_ws\/install\/setup.bash" && source "\/ros2_ws\/install\/setup.bash"/a \
            test -f /healthcheck_ws/install/setup.bash && source /healthcheck_ws/install/setup.bash\n \
            ros2 run healthcheck_pkg healthcheck_node &' \
            $entrypoint_file

COPY ./healthcheck.sh /
HEALTHCHECK --interval=2s --timeout=1s --start-period=20s --retries=1 \
    CMD ["/healthcheck.sh"]

