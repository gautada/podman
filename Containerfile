ARG ALPINE_VERSION=3.15.4
FROM gautada/alpine:$ALPINE_VERSION

LABEL source="https://github.com/gautada/podman-container.git"
LABEL maintainer="Adam Gautier <adam@gautier.org>"
LABEL description="This container is a podman installation for building OCI containers."

USER root

VOLUME /opt/podman

ARG PODMAN_VERSION
ARG PODMAN_PACKAGE="$PODMAN_VERSION"-r0
RUN /sbin/apk add --no-cache buildah podman=$PODMAN_PACKAGE fuse-overlayfs slirp4netns

COPY podman-bootstrap /usr/bin/podman-bootstrap
COPY podman-prune /etc/periodic/15min/podman-prune
COPY 10-profile.sh  /etc/profile.d/10-profile.sh
COPY 10-entrypoint.sh  /etc/entrypoint.d/10-entrypoint.sh

RUN /bin/cp /etc/ssh/sshd_config /etc/ssh/sshd_config~ \
 && /bin/echo "" >> /etc/ssh/sshd_config \
 && /bin/echo "" >> /etc/ssh/sshd_config \
 && /bin/echo "# ***** PODMAN CONTAINER - PODMAN SERVICE *****" >> /etc/ssh/sshd_config \
 && /bin/echo "" >> /etc/ssh/sshd_config \
 && /bin/echo "" >> /etc/ssh/sshd_config \
 && /bin/sed -i -e "/AllowTcpForwarding/s/^#*/# /" /etc/ssh/sshd_config \
 && /bin/echo "AllowTcpForwarding yes" >> /etc/ssh/sshd_config
 
RUN /bin/cp /etc/containers/storage.conf /etc/containers/storage.conf~ \
 && /bin/sed -i -e 's/#mount_program/mount_program/' /etc/containers/storage.conf 
 
 
ARG USER=podman
RUN /bin/mkdir -p /opt/$USER \
 && /usr/sbin/addgroup $USER \
 && /usr/sbin/adduser -D -s /bin/ash -G $USER $USER \
 && /usr/sbin/usermod -aG wheel $USER \
 && /usr/sbin/usermod --add-subuids 100000-165535 $USER \
 && /usr/sbin/usermod --add-subgids 100000-165535 $USER \
 && /bin/echo "$USER:$USER" | chpasswd \
 && /bin/touch /var/log/podman.log \
 && /bin/chown $USER:$USER -R /opt/$USER /var/log/podman.log
 
USER $USER
WORKDIR /home/$USER

# RUN podman system connection add local --identity /home/$USER/.ssh/podman_key ssh://localhost:22/tmp/podman-run-1000/podman/podman.sock \
# && podman system connection add x86 --identity /home/$USER/.ssh/podman_key_x86 ssh://$USER@podman-x86.cicd.svc.cluster.local:22/tmp/podman-run-1000/podman/podman.sock \
# && podman system connection add arm --identity /home/$USER/.ssh/podman_key_arm ssh://$USER@podman-arm.cicd.svc.cluster.local:22/tmp/podman-run-1000/podman/podman.sock
