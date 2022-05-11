#!/bin/ash
#
# Launch the podman service/process if not previously launched. If parameters are not provided
# launch as a process. If parameters provided fork the podman as a service.

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
