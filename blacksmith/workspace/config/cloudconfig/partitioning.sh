#!/usr/bin/bash

function partitioning {
	device=$(lsblk -i -o name,type | grep disk | cut -f 1 -d " ")
	partition=1
	echo "making partitions"
	echo -e "g\nn\n$partition\n\n\nw\n" | sudo fdisk /dev/$device
	sleep 1
	echo "making filesystem"
	sleep 1
	yes | mkfs.ext4 -L ROOT /dev/$device$partition &&  curl -X PUT "http://<< HostAddr >>/api/flag/state?mac=<< Mac >>&value=inited"
}

function usage {
	echo "-f for forcing to do partitioning"
	echo "-r for forcing to not reboot"
}


do_partitioning=false
reboot=true

# check for existence of root
if [ ! -e "/dev/disk/by-label/ROOT" ]; then
	do_partitioning=true
fi

# check for flags
while getopts "hfr" OPTION
do
	 case $OPTION in
		f)
			do_partitioning=true
		;;
		r)
			reboot=false
		;;
		h)
			usage
		;;
	 esac
done

if $do_partitioning; then
	partitioning
	if $reboot; then
		reboot
	fi
fi
