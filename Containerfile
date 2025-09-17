ARG ALPINE_VERSION=3.22
ARG IMAGE_NAME="podman"
ARG IMAGE_VERSION="5.6.1"

FROM gautada/alpine:$ALPINE_VERSION as CONTAINER

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL org.opencontainers.image.title="${IMAGE_NAME}"
LABEL org.opencontainers.image.description="A PodMan OCI managment container."
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
COPY entrypoint /etc/container/entrypoint

# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯
RUN /sbin/apk add --no-cache podman fuse-overlayfs \
 && /usr/sbin/usermod --add-subuids 100000-165535 $USER \
 && /usr/sbin/usermod --add-subgids 100000-165535 $USER 

# ╭――――――――――――――――――――╮
# │ CONFIGUTATION      │
# ╰――――――――――――――――――――╯
RUN /bin/chown -R $USER:$USER /home/$USER
USER $USER
VOLUME /mnt/volumes/backup
VOLUME /mnt/volumes/configmaps
VOLUME /mnt/volumes/container
VOLUME /mnt/volumes/secrets
EXPOSE 2375/tcp
WORKDIR /home/$USER

