#!/bin/bash

die() {
  echo
  echo "$@" 1>&2;
  exit 1
}

rm -r easy-rsa-master || echo "Not Fatal"
curl -L -O https://storage.googleapis.com/kubernetes-release/easy-rsa/easy-rsa.tar.gz || die "Failed while downloading the easy-rsa"
tar xzf easy-rsa.tar.gz
rm easy-rsa.tar.gz
