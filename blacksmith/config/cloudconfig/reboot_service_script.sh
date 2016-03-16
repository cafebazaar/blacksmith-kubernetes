#!/usr/bin/bash
# TODO: use blacksmith values
node_name=$(hostname -s)
cluster_name=$(hostname -d)

state_key=/$cluster_name/machines/$node_name/state

while true; do
	state = $(etcdctl watch $state_key)
	if [[ $state =~ ^"init-" ]]; then
		sudo systemctl reboot
	fi
done
