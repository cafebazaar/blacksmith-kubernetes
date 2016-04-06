#!/usr/bin/bash
IFS=. read node_name cluster_name << "<<<" >> $(hostname)

state_key=/$cluster_name/machines/$node_name/state

while true; do
	state = $(etcdctl watch $state_key)
	if [[ $state =~ ^"init-" ]]; then
		sudo systemctl reboot
	fi
done
