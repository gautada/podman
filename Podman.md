# Podman Notes

## Init machine

```shell
podman machine init --cpus 4 --disk-size 20 --memory 4096
```

## Connect to vm

```shell
ssh -p 62949 -i /Users/mada/.ssh/podman-machine-default core@localhost
```

## Build a volume on the machine

```shell
podman volume create --driver local --opt type=none \
  --opt device=/Volumes/Container --opt o=bind Container
```

## Run a container

```shell
podman create --interactive --name fluentd --publish-all --replace --rm --tty \
  --volume Container:/mnt/volumes/container localhost/fluent:dev
```

[Podman](https://podman.io) is a daemonless container engine for developing,
managing, and running Open Container Initiative (OCI) containers and container
images on your Linux System.

## Container

```shell
podman volume create --driver local --opt type=none \
  --opt device=/mnt/volumes/container/configmaps --opt o=bind Configmap
```

This container launches the `podman` system service, `sshd` for remote
connectivity, and `crond` for cleanup and maintenance.

### Versions

- April 30, 2022 [podman](https://podman.io/releases/) - Active version is
  3.4.7
- September 14, 2021 [podman](https://podman.io/releases/) - Active version
  is 3.2.3

### Bootstrap

As this is a core part of the build tool for containers a manual bootstrap
build must be defined to provide a mechanism to get this system initially
working. Follow the following steps to bootstrap `podman`.

1. Checkout the **podman-container** repository

   ```shell
   git clone https://github.com/gautada/podman-container.git
   cd podman-container
   ```

1. Build the local/docker version of the container.

   ```shell
   export ALPINE_VERSION="3.15.4"
   export PODMAN_VERSION="3.4.7"
   export PODMAN_PACKAGE="$PODMAN_VERSION"-r0
   docker build \
     --build-arg PODMAN_VERSION=$PODMAN_PACKAGE \
     --file Containerfile \
     --label revision="$(git rev-parse HEAD)" \
     --label version="$(date +%Y.%m.%d)" \
     --no-cache --tag podman:dev .
   ```

1. Launch the container and its services

   ```shell
   docker run --detach --name podman --privileged --rm podman:dev
   ```

1. Execute the shell

   ```shell
   docker exec --interactive --tty podman /bin/ash
   ```

1. Execute the bootstrap function to download the latest version of the
   `podman` container, build the container, label the container, and deploy
   the container to docker.io.

   ```shell
   bootstrap
   ```

   **Note:** Output is interactive and you will need to provide a valid
   password.

1. Clean-up the bootstrap environment.

   Leave the podman container used for bootstrap.

   ```shell
   exit
   ```

   Stop the podman container

   ```shell
   docker stop podman
   ```

**Note:** It is a good idea to check that `podman` is not running via
`docker ps -a` and to use `docker rmi` to remove any lingering images in
the bootstrap environment.

### Run

After bootstrap the latest container should be in the docker.io
[repository](https://hub.docker.com/repository/docker/gautada/podman/general).
To launch just `run` the tagged container.

```shell
docker run --detach --name podman --privileged --rm \
  docker.io/gautada/podman:3.4.7
```

### Configuration

#### Privileged

Podman container should be run with the `--privileged` flag.

#### Log Level

LOG_LEVEL = Default is info but can be overridden to debug, info, warn,
error, etc.

### SSH

**Note:** document SSH

**Note:** document remote configuration.

## Abstract

[Podman](https://podman.io) is a daemonless container engine for developing,
managing, and running OCI Containers on your Linux System. Containers can
either be run as root or in rootless mode.

## Configuration Notes for drone

- Test the CLI: `drone orgsecret info gautada password.docker.io`
