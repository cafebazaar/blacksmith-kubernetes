/usr/bin/etcdctl --endpoints http://<<.BlacksmithIP>>:2379 watch /cafecluster/workspace-hash; 
/usr/bin/curl -L http://<<.WebServerAddr>>/t/cc/<<.Mac>> -o /tmp/cloudconfig.yaml;
/usr/bin/coreos-install -d /dev/sda -c /tmp/cloudconfig.yaml -C beta -b http://<<.FileServerAddr>>;
/usr/bin/systemctl reboot