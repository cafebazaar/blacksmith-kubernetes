#!/bin/bash
CHANNEL=beta

command -v gpg >/dev/null 2>&1 || { echo >&2 "this script require The GNU Privacy Guard(gpg) but it's not installed.  Aborting."; exit 1; }

die() {
  echo
  echo "$@" 1>&2;
  exit 1
}

mkdir -p images
cd images;
wget -N http://${CHANNEL}.release.core-os.net/amd64-usr/current/version.txt || die "Failed while getting the latest version of CoreOS"
wget -N http://${CHANNEL}.release.core-os.net/amd64-usr/current/version.txt.sig || die "Failed while getting the signature of the latest version of CoreOS"
gpg --verify version.txt.sig || die "The downloaded version file is corrupted"

source version.txt

mkdir -p ${COREOS_VERSION}/
cd ${COREOS_VERSION};
wget -Nc http://${CHANNEL}.release.core-os.net/amd64-usr/${COREOS_VERSION}/coreos_production_pxe.vmlinuz || die "Failed while downloading the kernel image"
wget -Nc http://${CHANNEL}.release.core-os.net/amd64-usr/${COREOS_VERSION}/coreos_production_pxe.vmlinuz.sig || die "Failed while downloading the signature of the kernel image"
gpg --verify coreos_production_pxe.vmlinuz.sig || die "The downloaded kernel image is corrupted"
wget -Nc http://${CHANNEL}.release.core-os.net/amd64-usr/${COREOS_VERSION}/coreos_production_pxe_image.cpio.gz || die "Failed while downloading the initrd image"
wget -Nc http://${CHANNEL}.release.core-os.net/amd64-usr/${COREOS_VERSION}/coreos_production_pxe_image.cpio.gz.sig || die "Failed while downloading the signature of the initrd image"
gpg --verify coreos_production_pxe_image.cpio.gz.sig || die "The downloaded initrd image is corrupted"

# For coreos installation
wget -Nc http://${CHANNEL}.release.core-os.net/amd64-usr/${COREOS_VERSION}/coreos_production_image.bin.bz2 || die "Failed while downloading the installation image"
wget -Nc http://${CHANNEL}.release.core-os.net/amd64-usr/${COREOS_VERSION}/coreos_production_image.bin.bz2.sig || die "Failed while downloading the signature of the installation image"
gpg --verify coreos_production_image.bin.bz2.sig || die "The downloaded kernel image is corrupted"
cd ../..

echo "coreos-version: ${COREOS_VERSION}" > initial.yaml

echo
echo "========================================================================="
echo "Latest CoreOS Version @ Channel ${CHANNEL}: ${COREOS_VERSION}"
echo "========================================================================="
