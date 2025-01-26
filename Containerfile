ARG ALPINE_VERSION="latest"

FROM gautada/alpine:$ALPINE_VERSION as container
# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL source="https://github.com/gautada/deven-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="Podman container."

# ╭―
# │ USER
# ╰――――――――――――――――――――
ARG USER=podman
RUN /usr/sbin/usermod -l $USER alpine
RUN /usr/sbin/usermod -d /home/$USER -m $USER
RUN /usr/sbin/groupmod -n $USER alpine
RUN /bin/echo "$USER:$USER" | /usr/sbin/chpasswd


# ╭―
# │ PRIVILEGES
# ╰――――――――――――――――――――
COPY privileges /etc/container/privileges

# ╭―
# │ BACKUP
# ╰――――――――――――――――――――
# No backup needed and even disable the automated hourly backup
# COPY backup /etc/container/backup
RUN rm -f /etc/periodic/hourly/container-backup

# ╭―
# │ ENTRYPOINT
# ╰――――――――――――――――――――
COPY entrypoint /etc/container/entrypoint


# ╭――――――――――――――――――――╮
# │ STANDARD CONFIG    │
# ╰――――――――――――――――――――╯
# COPY backup /etc/container/backup
# COPY podman.health /etc/container/health.d/podman.health
# COPY entrypoint /etc/container/entrypoint
# COPY privileges /etc/container/privileges


# ╭――――――――――――――――――――╮
# │ APPLICATION        │
# ╰――――――――――――――――――――╯
 # ** CONTAINER MANAGER **
RUN /sbin/apk add --no-cache podman fuse-overlayfs
RUN /usr/sbin/usermod --add-subuids 100000-165535 $USER \
 && /usr/sbin/usermod --add-subgids 100000-165535 $USER 


# WORKDIR / 
# RUN /bin/mkdir -p /tmp/podman-run-1001/podman \
#  # && /bin/touch /tmp/podman-run-1001/podman/podman.sock \
#  && /usr/bin/podman system connection add sock unix:///tmp/podman-run-1001/podman/podman.sock \
#  &&  /usr/bin/podman system connection default sock \

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

