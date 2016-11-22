#!/usr/bin/env bash
$LOCALIP=$(ifconfig << (machine_variable "internal_interface_name") >>| sed -En 's/127.0.0.1//;s/.*inet (addr:)?(([0-9]*\.){3}[0-9]*).*/\2/p')
/usr/bin/etcdctl watch /cafecluster/machines/`echo '<<.Mac>>' | sed  s/://g`/workspace-revision;
/usr/bin/coreos-cloudinit -validate -from-url http://$LOCALIP:8000/t/cc/<<.Mac>>;
/usr/bin/curl -s -L http://$LOCALIP:8000/t/cc/<<.Mac>> -o /var/lib/coreos-install/user_data;
/usr/bin/coreos-cloudinit -from-url http://$LOCALIP:8000/t/cc/<<.Mac>>;
while true; do locksmithctl reboot; sleep 2; done
