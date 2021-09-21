# podman-container

[Podman](https://podman.io) is a daemonless container engine for developing, managing, and running Open Container Initiative (OCI) containers and container images on your Linux System.

## Container

### Build

#### Manual

ARM instance can be made on the Mac and/or RPI

```
podman --remote --connection arm build --build-arg ALPINE_TAG=3.14.2 --build-arg VERSION=3.2.3-r1 --file Containerfile --no-cache  --tag podman:dev .
podman --remote --connection arm tag podman:dev docker.io/gautada/podman:3.2.3-r1-arm
podman --remote --connection arm login --username=gautada docker.io
podman --remote --connection arm push docker.io/gautada/podman:3.2.3-r1-arm
```

x86 instance can be made on any x86_64 machine

```
export DOCKER_HOST=192.168.4.204
docker build --build-arg ALPINE_TAG=3.14.2 --build-arg VERSION=3.2.3-r1 --file Containerfile --no-cache --tag podman:dev .
docker tag podman:dev docker.io/gautada/podman:3.2.3-r1-x86
docker login --username=gautada docker.io
docker push docker.io/gautada/podman:3.2.3-r1-x86
unset DOCKER_HOST
```

### Run

#### Configuration

- Podman container should be run with the the `--privileged` flag
- Environment Variables
 - LOG_LEVEL = Default is info but can be overridden to debug, info, warn, error, etc. 
 

