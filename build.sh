#!/bin/bash

#It is recommended that you change the following settings:
#INITIAL_SERVER : Specifies the address fromwhich blacksmith/kubernetes master(s) will read the built directory
#up/var/kuber_env : These variables are injected in the cloudconfig files in cloud/ early on

INITIAL_SERVER=${INITIAL_SERVER:-192.168.1.1/blacksmith}

rm -rf build
mkdir build
cd build
mkdir blacksmith
mkdir cloud
mkdir coreos
#create /build/coreos/ver.sion.number containing three files:
#coreos_production_image.bin.bz2
#coreos_production_image.bin.bz2.sig
#coreos_production_iso_image.iso
mkdir coreos_install
mkdir kubernetes
mkdir kubernetes/bin
mkdir kubernetes/manifests
mkdir up
mkdir up/vars
mkdir utils
cd ..

source up/vars/kuber_env.sh
source blacksmith/blacksmith_variables.sh

cp blacksmith/* build/blacksmith/
envsubst < cloud/master.template.yaml > build/cloud/cloudconfig1.yaml
envsubst < cloud/black2.template.yaml > build/cloud/cloudconfig2.yaml
envsubst < cloud/black3.template.yaml > build/cloud/cloudconfig3.yaml


cp coreos_install/* build/coreos_install/


#put kube-proxy, kubectl, kubelet binaries in build/kubernetes/bin/
envsubst < manifests/apiserver.yaml > build/manifests/apiserver.yaml
envsubst < manifests/controller.yaml > build/manifests/controller.yaml
envsubst < manifests/scheduler.yaml > build/manifests/scheduler.yaml
cp kubernetes/* build/kubernetes/*


cp -r up build/up

cd build
grep --null -lr "REPO=X" | xargs --null sed -i 's|REPO=X|REPO=$INITIAL_SERVER|g'
cd ..

#put envsubst binary in build/utils
