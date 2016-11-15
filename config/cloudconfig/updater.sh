/usr/bin/etcdctl watch /cafecluster/workspace-hash;
rm -r -f /var/lib/blacksmith/workspaces/repo/;
docker -H unix:///var/run/early-docker.sock restart blacksmith;
/usr/bin/etcdctl watch /cafecluster/workspace-commit-hash;
/usr/bin/coreos-cloudinit -validate -from-url http://master.cafecluster:8000/t/cc/<<.Mac>>;
/usr/bin/curl -s -L http://master.cafecluster:8000/t/cc/<<.Mac>> -o /var/lib/coreos-install/user_data;
/usr/bin/coreos-cloudinit -from-url http://master.cafecluster:8000/t/cc/<<.Mac>>;
while true; do locksmithctl reboot; sleep 2; done