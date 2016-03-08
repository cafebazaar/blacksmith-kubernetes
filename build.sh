#!/bin/bash

#It is recommended that you change the following settings:
#up/var/kuber_env : These variables are injected in the cloudconfig files in cloud/ early on

rm -rf build
mkdir build
cd build
mkdir blacksmith
mkdir cloud
mkdir coreos
#create coreos/ver.sion.number containing three files:
#coreos_production_image.bin.bz2
#coreos_production_image.bin.bz2.sig
#coreos_production_iso_image.iso
mkdir coreos_install
mkdir kubernetes
mkdir kubernetes/bin
mkdir kubernetes/manifests
# will be created while copying
# mkdir up
# mkdir up/vars
mkdir utils
cd ..

source up/vars/kuber_env.sh
source blacksmith/blacksmith_variables.sh

cp blacksmith/* build/blacksmith/

cd blacksmith
tar -czf ../build/blacksmith/workspace.tar.gz workspace
cd ..

envsubst < cloud/master.template.yaml > build/cloud/cloudconfig1.yaml
envsubst < cloud/black2.template.yaml > build/cloud/cloudconfig2.yaml
envsubst < cloud/black3.template.yaml > build/cloud/cloudconfig3.yaml

cat up/vars/ssh-keys.yaml >> build/cloud/cloudconfig1.yaml
cat up/vars/ssh-keys.yaml >> build/cloud/cloudconfig2.yaml
cat up/vars/ssh-keys.yaml >> build/cloud/cloudconfig3.yaml

cp -r coreos/* build/coreos/

cp coreos_install/* build/coreos_install/

# Expects kube-proxy, kubectl, kubelet binaries in kubernetes/bin/
cp -r kubernetes/bin/* build/kubernetes/bin/

envsubst < kubernetes/manifests/apiserver.yaml > build/kubernetes/manifests/apiserver.yaml
envsubst < kubernetes/manifests/controller.yaml > build/kubernetes/manifests/controller.yaml
envsubst < kubernetes/manifests/scheduler.yaml > build/kubernetes/manifests/scheduler.yaml
cp kubernetes/certgen.sh build/kubernetes/
cp kubernetes/initiate_master.sh build/kubernetes/
cp kubernetes/setup.sh build/kubernetes/

#put envsubst binary in utils
cp utils/envsubst build/utils/envsubst

cp -r up build

cd build
#execute this line in build/ and replace SERVER with the http address which will correspond to this build/ direcotry
#grep --null -lr "REPO=X" | xargs --null sed -i 's|REPO=X|REPO=SERVER|g'
cd ..
