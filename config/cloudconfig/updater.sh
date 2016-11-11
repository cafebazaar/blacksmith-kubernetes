CURRENT_HASH=$(/usr/bin/etcdctl get cafecluster/workspace-hash);
BOOT_HASH=$(cat /var/lib/blacksmith/workspaces/workspace-hash);
if [[ "$CURRENT_HASH" != "$BOOT_HASH" ]];
    then
        /usr/bin/coreos-cloudinit --from-url http://master.cafecluster:8000/t/cc/<<.Mac>>;
        /usr/bin/locksmithctl reboot;
fi;
/usr/bin/etcdctl watch /cafecluster/workspace-hash; 
/usr/bin/coreos-cloudinit --from-url http://master.cafecluster:8000/t/cc/<<.Mac>>;
/usr/bin/watch /usr/bin/locksmithctl reboot;