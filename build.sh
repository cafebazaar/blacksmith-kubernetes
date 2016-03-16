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

#certificates
set -o errexit
set -o nounset
set -o pipefail

cert_ip=${BLACKSMITH_BOOTSTRAPPER1_IP}
extra_sans=${CERT_ARGS:-}
cert_dir=build/kubernetes/certificates
cert_group=kube-cert
#cert_group=docker

mkdir -p "$cert_dir"
use_cn=false

sans="IP:${cert_ip}"
if [[ -n "${extra_sans}" ]]; then
  sans="${sans},${extra_sans}"
fi
echo ${sans}

tmpdir=$(mktemp -d --tmpdir kubernetes_cacert.XXXXXX)
trap 'rm -rf "${tmpdir}"' EXIT
#tmpdir=xim
previous=$(pwd)
cd "${tmpdir}"

curl -L -O https://storage.googleapis.com/kubernetes-release/easy-rsa/easy-rsa.tar.gz 
tar xzf easy-rsa.tar.gz

cd easy-rsa-master/easyrsa3
./easyrsa init-pki

./easyrsa --batch "--req-cn=$cert_ip@`date +%s`" build-ca nopass

./easyrsa --subject-alt-name="${sans}" build-server-full kubernetes-master nopass
./easyrsa build-client-full kubelet nopass
./easyrsa build-client-full kubecfg nopass

cp -p pki/issued/kubernetes-master.crt "${cert_dir}/server.cert" 
cp -p pki/private/kubernetes-master.key "${cert_dir}/server.key" 
cp -p pki/ca.crt "${cert_dir}/ca.crt"
cp -p pki/issued/kubecfg.crt "${cert_dir}/kubecfg.crt"
cp -p pki/private/kubecfg.key "${cert_dir}/kubecfg.key"
cp -p pki/issued/kubelet.crt "${cert_dir}/kubelet.crt"
cp -p pki/private/kubelet.key "${cert_dir}/kubelet.key"
cp -p pki/issued/kubecfg.crt "${cert_dir}/kubecfg.crt"
cp -p pki/private/kubecfg.key "${cert_dir}/kubecfg.key"


# Make server certs accessible to apiserver.
sudo chgrp $cert_group "${cert_dir}/server.key" "${cert_dir}/server.cert" "${cert_dir}/ca.crt"
sudo chmod 660 "${cert_dir}/server.key" "${cert_dir}/server.cert" "${cert_dir}/ca.crt"
cd $previous

envsubst < kubernetes/manifests/apiserver.yaml > build/kubernetes/manifests/apiserver.yaml
envsubst < kubernetes/manifests/controller.yaml > build/kubernetes/manifests/controller.yaml
envsubst < kubernetes/manifests/scheduler.yaml > build/kubernetes/manifests/scheduler.yaml
cp kubernetes/certgen.sh build/kubernetes/
cp kubernetes/initiate_master.sh build/kubernetes/
cp kubernetes/setup.sh build/kubernetes/
