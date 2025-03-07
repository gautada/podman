ARG ALPINE_VERSION=latest

# │ STAGE: CONTAINER
# ╰――――――――――――――――――――――――――――――――――――――――――――――――――――――
FROM gautada/alpine:$ALPINE_VERSION as CONTAINER

# ╭――――――――――――――――――――╮
# │ VARIABLES          │
# ╰――――――――――――――――――――╯
ARG IMAGE_VERSION="5.3.2-r2"

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL org.opencontainers.image.title="postgresql"
LABEL org.opencontainers.image.description="A PostgreSQL database container."
LABEL org.opencontainers.image.url="https://hub.docker.com/r/gautada/postgresql"
LABEL org.opencontainers.image.source="https://github.com/gautada/postgresql"
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

# ╭―
# │ ENTRYPOINT
# ╰――――――――――――――――――――
COPY entrypoint /etc/container/entrypoint

# ╭――――――――――――――――――――╮
# │APPLICATION        │
# ╰――――――――――――――――――――╯
RUN /bin/sed -i 's|dl-cdn.alpinelinux.org/alpine/|mirror.math.princeton.edu/pub/alpinelinux/|g' /etc/apk/repositories
RUN /sbin/apk add --no-cache podman fuse-overlayfs
RUN /usr/sbin/usermod --add-subuids 100000-165535 $USER \
 && /usr/sbin/usermod --add-subgids 100000-165535 $USER 

# ╭――――――――――――――――――――╮
# │ CONTAINER          │
# ╰――――――――――――――――――――╯
RUN /bin/chown -R $USER:$USER /home/$USER
USER $USER
VOLUME /mnt/volumes/backup
VOLUME /mnt/volumes/configmaps
VOLUME /mnt/volumes/container
VOLUME /mnt/volumes/secrets
VOLUME /mnt/volumes/source
EXPOSE 2375/tcp
# EXPOSE 2376/tcp # For encrypted connections using TLS
WORKDIR /home/$USER

