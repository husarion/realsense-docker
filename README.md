<h1 align="center">
  Docker Images for RealSense D400 Series
</h1>

The repository includes a GitHub Actions workflow that automatically deploys built Docker images to the [husarion/realsense-docker](https://hub.docker.com/r/husarion/realsense) Docker Hub repositories. This process is based on [realsense-ros](https://github.com/IntelRealSense/realsense-ros) repository.

[![ROS Docker Image](https://github.com/husarion/realsense-docker/actions/workflows/ros-docker-image.yaml/badge.svg)](https://github.com/husarion/realsense-docker/actions/workflows/ros-docker-image.yaml)

## Prepare Environment

**1. Plugin the Device**

For best performance please use **USB 2.0/3.0** port, depend of the camera model. Then use `lsusb` command to check if the device is visible.

## Demo

**1. Clone the Repository**

```bash
git clone https://github.com/husarion/realsense-docker.git
cd realsense-docker/demo
```
**2. Activate the Device**

```bash
docker compose up realsense
```

**3. Launch Visualization**

```bash
xhost local:root
docker compose up rviz
```

> [!NOTE]
> You can run the visualization on any device, provided that it is connected to the computer to which the sensor is connected.
