# Reboot service using etcd

## how to use it
Embed the `reboot.service` in the cloud-config file which is served to machines, and set the `FILE_SERVER_ADDRESS` environment variable from which the service can obtain the `reb.sh` file.
see example.yaml where reb.sh is obtained from a local file server. you can also `wget` the raw file directly from this repo.
