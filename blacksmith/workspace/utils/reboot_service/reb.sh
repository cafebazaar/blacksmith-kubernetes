#!/usr/bin/bash
label=$(hostname)

should_reboot_key=/blacksmith/machines/$label/should_reboot
rebooted_key=/blacksmith/machines/$label/rebooted


etcdctl mk $should_reboot_key 0
etcdctl mk $rebooted_key 1

if [ $(etcdctl get $rebooted_key) == 1 ]; then
	etcdctl set $rebooted_key 0
	etcdctl set $should_reboot_key 0
fi

while true; do
	if [ $(etcdctl watch $should_reboot_key) == "1" ]; then
		etcdctl set $rebooted_key 1
		sudo systemctl reboot
	fi

done

