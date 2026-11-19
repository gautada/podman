#!/bin/sh
# container-version: returns the installed podman version.
# Called by container-health and appversion-check to determine the
# running version of this container's primary application.
/usr/bin/podman --version | awk '{print $3}'
