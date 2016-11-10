#!/usr/bin/bash
node_name=$(echo $(hostname) | cut -f1 -d.)
cluster_name=$(echo $(hostname) | cut -f2 -d.)

state_key=/$cluster_name/machines/$node_name/state

while true; do
	state=$(etcdctl watch $state_key)
	if [[ $state =~ ^"init-" ]]; then
		sudo systemctl reboot
	fi
done
