bootstrap() {
 git clone https://github.com/gautada/podman-container.git
 cd podman-container
 DOCKERIO_ACCOUNT=gautada
 PODMAN_VERSION="3.4.7"
 PODMAN_PACKAGE="$PODMAN_VERSION"-r0 ;
 podman build --build-arg PODMAN_VERSION=$PODMAN_PACKAGE --file Containerfile --label revision="$(git rev-parse HEAD)" --label version="$(date +%Y.%m.%d)" --no-cache --tag podman:dev .
 podman tag podman:dev docker.io/$DOCKERIO_ACCOUNT/podman:$PODMAN_VERSION
 podman login --username=$DOCKERIO_ACCOUNT docker.io
 podman push docker.io/$DOCKERIO_ACCOUNT/podman:$PODMAN_VERSION
}
