/usr/bin/etcdctl --endpoints <<.EtcdCtlEndpoints>> watch /cafecluster/workspace-hash; 
/usr/bin/coreos-cloudinit -validate -from-url http://<<.WebServerAddr>>/t/cc/<<.Mac>>;
/usr/bin/curl -L http://<<.WebServerAddr>>/t/cc/<<.Mac>> -o /tmp/cloudconfig.yaml;
/usr/bin/coreos-install -d /dev/sda -c /tmp/cloudconfig.yaml -C beta -b <<.FileServerAddr>>;
/usr/bin/systemctl reboot 