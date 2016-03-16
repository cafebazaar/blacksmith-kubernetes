#!/bin/bash

die() {
  echo
  echo "$@" 1>&2;
  exit 1
}

curl -O https://storage.googleapis.com/kubernetes-release/release/v1.2.0-beta.1/bin/linux/amd64/kubectl || die "Failed while downloading the kubernetes binary"
