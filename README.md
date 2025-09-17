# podman
<<<<<<< HEAD
=======

FF: [Podman](https://podman.io) Manage containers, pods, and images with Podman. Seamlessly work with containers and Kubernetes from your local environment.
>>>>>>> 0302c33 (FF trying updated cicd)

[Podman](https://podman.io) Manage containers, pods, and images with Podman.
Seamlessly work with containers and Kubernetes from your local environment.

## Volumes

Volumes are very important to make the podman container work like the k8s
environment the containers will be running within.

```/bin/zsh
podman volume create --driver local --opt type=none --opt device=/Users/mada/.cache/containers/backup --opt o=bind Backup
```
