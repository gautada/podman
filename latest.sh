#!/bin/sh
# container-latest: returns the latest containers/podman release tag from GitHub.
# Strips the leading 'v' prefix to return a bare semver string.
# Called by appversion-check to compare running version against upstream.
curl -sL "https://api.github.com/repos/containers/podman/releases/latest" \
  | jq -r '.tag_name' \
  | sed 's/^v//' \
  | tr -d '[:space:]'
