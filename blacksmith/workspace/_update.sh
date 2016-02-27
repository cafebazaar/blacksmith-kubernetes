#!/bin/bash

WORKSPACE_DIR=$1
CHANNEL=$2

die() {
  echo
  echo "$@" 1>&2;
  exit 1
}

mkdir -p ${WORKSPACE_DIR}/images
cd ${WORKSPACE_DIR}/images;
wget -N http://${CHANNEL}.release.core-os.net/amd64-usr/current/version.txt || die "Failed while getting the latest version of CoreOS"
wget -N http://${CHANNEL}.release.core-os.net/amd64-usr/current/version.txt.sig || die "Failed while getting the signature of the latest version of CoreOS"
cd ../..

gpg --no-default-keyring --keyring ${WORKSPACE_DIR}/keyring/keyring.gpg --verify ${WORKSPACE_DIR}/images/version.txt.sig || die "The downloaded version file is corrupted"
source ${WORKSPACE_DIR}/images/version.txt

echo "Latest CoreOS Version @ Channel ${CHANNEL}: ${COREOS_VERSION}"

mkdir -p ${WORKSPACE_DIR}/images/${COREOS_VERSION}/
cd ${WORKSPACE_DIR}/images/${COREOS_VERSION};
wget -Nc http://${CHANNEL}.release.core-os.net/amd64-usr/${COREOS_VERSION}/coreos_production_pxe.vmlinuz || die "Failed while downloading the kernel image"
wget -Nc http://${CHANNEL}.release.core-os.net/amd64-usr/${COREOS_VERSION}/coreos_production_pxe.vmlinuz.sig || die "Failed while downloading the signature of the kernel image"
gpg --no-default-keyring --keyring ../../keyring/keyring.gpg --verify coreos_production_pxe.vmlinuz.sig || die "The downloaded kernel image is corrupted"
wget -Nc http://${CHANNEL}.release.core-os.net/amd64-usr/${COREOS_VERSION}/coreos_production_pxe_image.cpio.gz || die "Failed while downloading the initrd image"
wget -Nc http://${CHANNEL}.release.core-os.net/amd64-usr/${COREOS_VERSION}/coreos_production_pxe_image.cpio.gz.sig || die "Failed while downloading the signature of the initrd image"
gpg --no-default-keyring --keyring ../../keyring/keyring.gpg --verify coreos_production_pxe_image.cpio.gz.sig || die "The downloaded initrd image is corrupted"
cd ../../..

echo "coreos-version: ${COREOS_VERSION}" > ${WORKSPACE_DIR}/initial.yaml

echo
echo "========================================================================="
echo "Latest CoreOS Version @ Channel ${CHANNEL}: ${COREOS_VERSION}"
echo "Aghajoon Workspace is ready: $(realpath ${WORKSPACE_DIR})"
echo "========================================================================="
