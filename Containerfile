ARG DEBIAN_VERSION=13.7
ARG IMAGE_NAME=podman

FROM docker.io/gautada/debian:${DEBIAN_VERSION} AS container

# ╭――――――――――――――――――――╮
# │ METADATA           │
# ╰――――――――――――――――――――╯
LABEL org.opencontainers.image.title="${IMAGE_NAME}"
LABEL org.opencontainers.image.description="A podman OCI management container."
LABEL org.opencontainers.image.url="https://hub.docker.com/r/gautada/podman"
LABEL org.opencontainers.image.source="https://github.com/gautada/podman"
LABEL org.opencontainers.image.license="Upstream"

# ╭――――――――――――――――――――╮
# │ USER               │
# ╰――――――――――――――――――――╯
# Switch to root for user/package setup. The base image sets USER=debian
# which locks the account for usermod during build (PID 1 runs as debian).
USER root

# Rename the base debian user to bob. Follows the same pattern as other
# gautada containers (e.g. gautada/homepage, gautada/node).
ARG OLDUSER=debian
ARG USER=bob
RUN /usr/sbin/usermod -l $USER $OLDUSER \
 && /usr/sbin/usermod -d /home/$USER -m $USER \
 && /usr/sbin/groupmod -n $USER $OLDUSER \
 && /bin/echo "$USER:$USER" | /usr/sbin/chpasswd

# ╭――――――――――――――――――――╮
# │ PRIVILEGES         │
# ╰――――――――――――――――――――╯
# COPY privileges /etc/container/privileges

# ╭――――――――――――――――――――╮
# │ PACKAGES           │
# ╰――――――――――――――――――――╯
# Install podman and fuse-overlayfs for rootless container operation.
# DL3008: package version pinning is not practical for system-level
# packages resolved via apt; suppressed explicitly.
# hadolint ignore=DL3008
RUN apt-get update \
 && apt-get install -y --no-install-recommends \
      curl \
      fuse-overlayfs \
      jq \
      uidmap \
      passt \
      nftables \
      podman \
 && apt-get clean \
 && rm -rf /var/lib/apt/lists/*

# ╭――――――――――――――――――――╮
# │ ROOTLESS SETUP     │
# ╰――――――――――――――――――――╯
# Allocate subordinate uid/gid ranges required for rootless podman.
RUN /usr/sbin/usermod --add-subuids 100000-165535 $USER \
 && /usr/sbin/usermod --add-subgids 100000-165535 $USER

# ╭――――――――――――――――――――╮
# │ TEST FILE          │
# ╰――――――――――――――――――――╯
COPY --chown=$USER:$USER Containerfile.test /home/$USER/Containerfile

# ╭――――――――――――――――――╮
# │ VERSION          │
# ╰――――――――――――――――――╯
# Override the base image's Debian version reporter with the application
# version expected by the container version and health mechanisms.
COPY usr/bin/container-version /usr/bin/container-version
RUN chmod 0755 /usr/bin/container-version
# # Resolve the latest containers/podman release from GitHub API at build time.
# # Fails the build if the API returns empty or null — no silent fallback.
# # Logs both the installed apt version and the current upstream release.
# RUN PODMAN_LATEST=$(curl -sL "https://api.github.com/repos/containers/podman/releases/latest" \
#     | jq -r '.tag_name' \
#     | sed 's/^v//' \
#     | tr -d '[:space:]') \
#  && { [ -n "$PODMAN_LATEST" ] && [ "$PODMAN_LATEST" != "null" ] \
#       || { echo "ERROR: failed to resolve latest podman version from GitHub API" >&2; exit 1; }; } \
#  && echo "Latest podman release (GitHub): ${PODMAN_LATEST}" \
#  && echo "Installed podman version: $(podman --version | awk '{print $3}')"
# 
# # Provides /usr/bin/container-version — returns installed podman version.
# COPY version.sh /usr/bin/container-version
# RUN chmod +x /usr/bin/container-version

# ╭――――――――――――――――――――╮
# │ LATEST             │
# ╰――――――――――――――――――――╯
# Provides /usr/bin/container-latest — fetches the latest release tag
# from containers/podman on GitHub (strips 'v' prefix).
COPY usr/bin/container-latest /usr/bin/container-latest
RUN chmod +x /usr/bin/container-latest

# ╭――――――――――――――――――――╮
# │ ENTRYPOINT         │
# ╰――――――――――――――――――――╯
# s6 service definition: starts podman as a headless TCP service.
COPY --chown=$USER:uucp etc/services.d/podman/run /etc/services.d/podman/run
RUN chmod +x /etc/services.d/podman/run

# ╭――――――――――――――――――――╮
# │ CONFIGURATION      │
# ╰――――――――――――――――――――╯
# Copy storage.conf to the persistent configuration volume mount point and
# symlink it into /etc/containers/ so podman picks it up system-wide.
COPY etc/containers/storage.conf /mnt/volumes/configuration/storage.conf
RUN ln -sf /mnt/volumes/configuration/storage.conf /etc/containers/storage.conf

RUN mkdir -pv /mnt/volumes/data/data \
              /mnt/volumes/data/secrets \
              /mnt/volumes/data/backup \
              /mnt/volumes/data/configmaps \
 && /bin/chown -R $USER:$USER /home/$USER

ARG PODMAN_PORT=2375
EXPOSE ${PODMAN_PORT}/tcp
WORKDIR /home/$USER
USER $USER
