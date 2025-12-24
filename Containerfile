ARG ALPINE_VERSION=3.23
ARG IMAGE_NAME="podman"
ARG IMAGE_VERSION="5.6.1"

FROM gautada/alpine:$ALPINE_VERSION as CONTAINER

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL org.opencontainers.image.title="${IMAGE_NAME}"
LABEL org.opencontainers.image.description="A podman OCI managment container."
LABEL org.opencontainers.image.url="https://hub.docker.com/r/gautada/podman"
LABEL org.opencontainers.image.source="https://github.com/gautada/podman"
LABEL org.opencontainers.image.version="${CONTAINER_VERSION}"
LABEL org.opencontainers.image.license="Upstream"

# ╭――――――――――――――――――――╮
# │ USER               │ 
# ╰――――――――――――――――――――╯
ARG USER=podman
SHELL ["/bin/ash", "-o", "pipefail", "-c"]
RUN /usr/sbin/usermod -l $USER alpine \
 && /usr/sbin/usermod -d /home/$USER -m $USER \
 && /usr/sbin/groupmod -n $USER alpine \
 && /bin/echo "$USER:$USER" | /usr/sbin/chpasswd

# ╭――――――――――――――――――――╮
# │ PRIVILEGES         │
# ╰――――――――――――――――――――╯
COPY privileges /etc/container/privileges

# ╭――――――――――――――――――――╮
# │ BACKUPS            │
# ╰――――――――――――――――――――╯
# No backup needed and even disable the automated hourly backup
# COPY backup /etc/container/backup
# RUN rm -f /etc/periodic/hourly/container-backup

# ╭――――――――――――――――――――╮
# │ ENTRYPOINT         │
# ╰――――――――――――――――――――╯
COPY container.init /etc/services.d/container/run

# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯
RUN /sbin/apk add --no-cache podman fuse-overlayfs \
 && /usr/sbin/usermod --add-subuids 100000-165535 $USER \
 && /usr/sbin/usermod --add-subgids 100000-165535 $USER 

ARG PODMAN_PORT=2375
RUN mkdir -pv /mnt/volumes/data/data \
 /mnt/volumes/data/secrets \
 /mnt/volumes/data/backup \
 /mnt/volumes/data/configmaps

# RUN /usr/bin/podman system service --time 0 tcp://0.0.0.0:$PODMAN_PORT &
# RUN PODMAN_PID=$!
# RUN echo "${PODMAN_PID}"
# RUN /usr/bin/podman volume create --driver local --opt type=none --opt device=/mnt/volumes/container/data --opt o=bind Data


# ╭――――――――――――――――――――╮
# │ CONFIGUTATION      │
# ╰――――――――――――――――――――╯
RUN /bin/chown -R $USER:$USER /home/$USER
USER $USER
# VOLUME /mnt/volumes/backup
# VOLUME /mnt/volumes/configmaps
# VOLUME /mnt/volumes/container
# VOLUME /mnt/volumes/secrets
EXPOSE 2375/tcp
WORKDIR /home/$USER

RUN /usr/bin/podman system connection add --default pod tcp://localhost:$PODMAN_PORT
