<h1 align="center">
  Docker Images for Intel RealSense D400 Series cameras.
</h1>

The repository contains a Docker, demo and GitHub Actions to create Docker images for RealSense Camera.

## Available Docker Images

You can find all build and tested Dockerfile Images on [Husarion DockerHub](https://hub.docker.com/r/husarion/realsense).


## Demo

### Prerequisites

- [Docker Engine and Docker Compose](https://docs.docker.com/engine/install/).

### Quick guide

**1. Clone repository**

```bash
git clone https://github.com/husarion/realsense-docker.git
```

**2. Pulling the Docker images**

```bash
cd realsense/demo
docker compose pull
```

**3. Run `compose.yaml`**

```bash
xhost local:root
docker compose up
```
