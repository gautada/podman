#!/bin/ash
#
# If no params and not previously launched then launch as a service process.

echo "$0"
TEST="$(/usr/bin/pgrep podman)"
if [ $? -eq 1 ] ; then
 echo "---------- [ CONTAINER MANAGER(podman) ] ----------"
 if [ -z "$ENTRYPOINT_PARAMS" ] ; then
  /usr/bin/podman --log-level info system service --time 0
  return 1
 else
  /usr/bin/podman --log-level fatal system service --time 0 &
 fi
fi
