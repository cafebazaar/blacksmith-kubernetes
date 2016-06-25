#!/bin/bash

die() {
  echo
  echo "$@" 1>&2;
  exit 1
}

URL_PREFIX=https://storage.googleapis.com/kubernetes-release/release/v1.2.4/bin/linux/amd64

curl -O $URL_PREFIX/kubectl || die "Failed while downloading the kubernetes binary (kubectl)"
chmod +x kubectl
#curl -O $URL_PREFIX/kubelet || die "Failed while downloading the kubernetes binary (kubelet)"
#curl -O $URL_PREFIX/kube-proxy || die "Failed while downloading the kubernetes binary (kube-proxy)"
