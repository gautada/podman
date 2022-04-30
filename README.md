# podman-container

[Podman](https://podman.io) is a daemonless container engine for developing, managing, and running Open Container Initiative (OCI) containers and container images on your Linux System.  

## Container

This container launches the `podman` system service, `sshd` for remote connectivity, and `crond` for cleanup and maintenance.
 
### Versions

- April 30, 2022 [podman](https://podman.io/releases/) - Active version is [3.4 .7](https://pkgs.alpinelinux.org/packages?name=podman&branch=3.15)
- September 14, 2021 [podman](https://podman.io/releases/) - Active version is [3.2 .3](https://pkgs.alpinelinux.org/packages?name=podman&branch=edge)

### Build

As this is a core part of the build system for containers a manual build must be defined to provide a mechanism to boot-strap the build system.

```
export PODMAN_VERSION="3.4.7" ; export PODMAN_PACKAGE="$PODMAN_VERSION"-r0 ; docker build --build-arg PODMAN_VERSION=$PODMAN_PACKAGE --file Containerfile --label revision="$(git rev-parse HEAD)" --label version="$(date +%Y.%m.%d)" --no-cache --tag podman:dev .
```

### Run

Launch the container and it's services

```
docker run --detach --name podman --rm podman:dev
```

To test and bootstrap the system just execute the shell, then run `bootstrap`
```
docker exec --interactive --tty podman /bin/ash
```

The bootstrap function will download the latest version of the `podman` container, build the container, label the container, and deploy the container to docker.io.
```
bootstrap
```

### Configuration

- Podman container should be run with the the `--privileged` flag
- Environment Variables
 - LOG_LEVEL = Default is info but can be overridden to debug, info, warn, error, etc. 
 

