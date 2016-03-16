#!/bin/bash

# Variables are injected from this configuration file:
export DOLLAR='$'
source kuber_env.sh
int2ip() {
    local ui32=$1; shift
    local ip n
    for n in 1 2 3 4; do
        ip=$((ui32 & 0xff))${ip:+.}$ip
        ui32=$((ui32 >> 8))
    done
    echo -n $ip
}

netmask() {
    local mask=$((0xffffffff << (32 - $1))); shift
    int2ip $mask
}

export INTERNAL_NETWORK_NETMASK=$(netmask ${INTERNAL_NETWORK_NETSIZE})


## Clean
rm -rf build


## Blacksmith Workspace
mkdir -p build/workspace/files

cp -r binaries/images build/workspace/
cp binaries/initial.yaml build/workspace/
cp -r blacksmith/config build/workspace/

cp ssh-keys.yaml >> build/workspace/config/cloudconfig/ssh_authorized_keys.yaml
envsubst < blacksmith/templates/bootstrapper1.yaml > build/workspace/config/cloudconfig/bootstrapper1.yaml
envsubst < blacksmith/templates/bootstrapper2.yaml > build/workspace/config/cloudconfig/bootstrapper2.yaml
envsubst < blacksmith/templates/bootstrapper3.yaml > build/workspace/config/cloudconfig/bootstrapper3.yaml
envsubst < blacksmith/templates/common-units.yaml > build/workspace/config/cloudconfig/common-units.yaml
envsubst < blacksmith/blacksmith_install.sh > build/workspace/files/blacksmith_install.sh
envsubst < blacksmith/templates/worker-units.yaml > build/workspace/config/cloudconfig/worker-units.yaml
envsubst < blacksmith/templates/worker.yaml > build/workspace/config/cloudconfig/worker.yaml

exit


envsubst < kubernetes/manifests/apiserver.yaml > build/kubernetes/manifests/apiserver.yaml
envsubst < kubernetes/manifests/controller.yaml > build/kubernetes/manifests/controller.yaml
envsubst < kubernetes/manifests/scheduler.yaml > build/kubernetes/manifests/scheduler.yaml
cp kubernetes/certgen.sh build/kubernetes/
cp kubernetes/initiate_master.sh build/kubernetes/
cp kubernetes/setup.sh build/kubernetes/
