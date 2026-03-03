ARG CONTAINER_VERSION=13.3
ARG IMAGE_NAME=podman

FROM docker.io/gautada/debian:${CONTAINER_VERSION} AS container

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
# Rename the base debian user to podman.
# Follows the same pattern as other gautada containers.
ARG USER=podman
RUN /usr/sbin/usermod -l $USER debian \
 && /usr/sbin/usermod -d /home/$USER -m $USER \
 && /usr/sbin/groupmod -n $USER debian \
 && /bin/echo "$USER:$USER" | /usr/sbin/chpasswd

# ╭――――――――――――――――――――╮
# │ PRIVILEGES         │
# ╰――――――――――――――――――――╯
COPY privileges /etc/container/privileges

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
# │ VERSION            │
# ╰――――――――――――――――――――╯
# Resolve the latest containers/podman release from GitHub API at build time.
# Fails the build if the API returns empty or null — no silent fallback.
# Logs both the installed apt version and the current upstream release.
RUN PODMAN_LATEST=$(curl -sL "https://api.github.com/repos/containers/podman/releases/latest" \
    | jq -r '.tag_name' \
    | sed 's/^v//' \
    | tr -d '[:space:]') \
 && { [ -n "$PODMAN_LATEST" ] && [ "$PODMAN_LATEST" != "null" ] \
      || { echo "ERROR: failed to resolve latest podman version from GitHub API" >&2; exit 1; }; } \
 && echo "Latest podman release (GitHub): ${PODMAN_LATEST}" \
 && echo "Installed podman version: $(podman --version | awk '{print $3}')"

# Provides /usr/bin/container-version — returns installed podman version.
COPY version.sh /usr/bin/container-version
RUN chmod +x /usr/bin/container-version

# ╭――――――――――――――――――――╮
# │ LATEST             │
# ╰――――――――――――――――――――╯
# Provides /usr/bin/container-latest — fetches the latest release tag
# from containers/podman on GitHub (strips 'v' prefix).
COPY latest.sh /usr/bin/container-latest
RUN chmod +x /usr/bin/container-latest

# ╭――――――――――――――――――――╮
# │ ENTRYPOINT         │
# ╰――――――――――――――――――――╯
# s6 service definition: starts podman as a headless TCP service.
COPY container.init /etc/services.d/container/run
RUN chmod +x /etc/services.d/container/run

# ╭――――――――――――――――――――╮
# │ CONFIGURATION      │
# ╰――――――――――――――――――――╯
RUN mkdir -pv /mnt/volumes/data/data \
              /mnt/volumes/data/secrets \
              /mnt/volumes/data/backup \
              /mnt/volumes/data/configmaps \
 && /bin/chown -R $USER:$USER /home/$USER

ARG PODMAN_PORT=2375
EXPOSE ${PODMAN_PORT}/tcp
WORKDIR /home/$USER
