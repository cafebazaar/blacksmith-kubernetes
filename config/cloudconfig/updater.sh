/usr/bin/etcdctl watch /cafecluster/workspace-hash;
docker -H unix:///var/run/early-docker.sock pull  << (cluster_variable "blacksmith_image") >>; 
docker -H unix:///var/run/early-docker.sock restart blacksmith;
/usr/bin/etcdctl watch /cafecluster/workspace-commit-hash;
/usr/bin/coreos-cloudinit --from-url http://master.cafecluster:8000/t/cc/<<.Mac>>;
while true; do locksmithctl reboot; sleep 2; done