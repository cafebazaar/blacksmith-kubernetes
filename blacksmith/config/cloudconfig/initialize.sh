#!/usr/bin/bash

device=$(lsblk -i -o name,type | grep disk | cut -f 1 -d " ")

function partition_disk {
	curl -X PUT "http://<< .HostAddr >>/api/flag/state?mac=<< .Mac >>&value=starting-<< V "state" >>"
	partition=1
	echo "making partitions"
	echo -e "g\nn\n$partition\n\n\nw\n" | fdisk /dev/$device
	sleep 1
	echo "making filesystem"
	sleep 1
	yes | mkfs.ext4 -L ROOT /dev/$device$partition  &&  curl -X PUT "http://<< .HostAddr >>/api/flag/state?mac=<< .Mac >>&value=worker"
}

function install_coreos {
	DEVICE=/dev/$device
	WORKDIR=$(mktemp --tmpdir -d init-install-coreos.XXXXXXXXXX)

	curl -X PUT "http://<< .HostAddr >>/api/flag/state?mac=<< .Mac >>&value=<< V "desired-state" >>"
	curl -L "http://<< .HostAddr >>/t/cc/<< .Mac >>" -o $WORKDIR/cloudconfig.yaml

	coreos-install -c $WORKDIR/cloudconfig.yaml -d $DEVICE -b http://<< .HostAddr >>/images/

	ROOT_DEV=$(blkid -t "LABEL=ROOT" -o device "${DEVICE}"*)

	if [[ -z "${ROOT_DEV}" ]]; then
			echo "Unable to find new ROOT partition on ${DEVICE}" >&2
			exit 1
	fi

	mkdir -p "${WORKDIR}/rootfs"
	case $(blkid -t "LABEL=ROOT" -o value -s TYPE "${ROOT_DEV}") in
		"btrfs") mount -t btrfs -o subvol=root "${ROOT_DEV}" "${WORKDIR}/rootfs" ;;
		*)       mount "${ROOT_DEV}" "${WORKDIR}/rootfs" ;;
	esac
	trap "umount '${WORKDIR}/rootfs' && rm -rf '${WORKDIR}'" EXIT
	mkdir -p "${WORKDIR}/rootfs/var/lib/blacksmith"
	curl -L "http://<< .HostAddr >>/files/workspace.tar" -o ${WORKDIR}/workspace.tar
	tar -C ${WORKDIR}/rootfs/var/lib/blacksmith/ xf ${WORKDIR}/workspace.tar
	# To make it possible to reproduce special nodes without BoB. Be careful humans!
	mv ${WORKDIR}/workspace.tar ${WORKDIR}/rootfs/var/lib/blacksmith/workspace/files/

  umount "${WORKDIR}/rootfs"
	rm -rf "${WORKDIR}"
  trap - EXIT

	curl -X PUT "http://<< .HostAddr >>/api/flag/state?mac=<< .Mac >>&value=installed"
}

function usage {
	echo "-f for forcing to do partitioning"
	echo "-i for installing coreos instead of partitioning"
	echo "-r for disabling the reboot after the process"
}


do_partitioning=false
do_install=false
reboot=true

# check for existence of root
if [ ! -e "/dev/disk/by-label/ROOT" ]; then
	do_partitioning=true
fi

# check for flags
while getopts "hfri" OPTION
do
	 case $OPTION in
		f)
			do_partitioning=true
		;;
		i)
			do_install=true
		;;
		r)
			reboot=false
		;;
		h)
			usage
		;;
	 esac
done

if $do_install; then
	install_coreos
elif $do_partitioning; then
	partition_disk
fi

if $reboot; then
	reboot
fi
