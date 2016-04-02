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
rm -rf workspace


## Blacksmith Workspace
mkdir -p workspace/files

cp -r binaries/images workspace/
cp binaries/initial.yaml workspace/
cp -r blacksmith/config workspace/

# For coreos-install
cd workspace/files
ln -s ../images ./images
cd ../..

cp ssh-keys.yaml workspace/config/cloudconfig/ssh_authorized_keys.yaml
envsubst < blacksmith/templates/bootstrapper1.yaml > workspace/config/cloudconfig/bootstrapper1.yaml
envsubst < blacksmith/templates/bootstrapper2.yaml > workspace/config/cloudconfig/bootstrapper2.yaml
envsubst < blacksmith/templates/bootstrapper3.yaml > workspace/config/cloudconfig/bootstrapper3.yaml
envsubst < blacksmith/templates/common-units.yaml > workspace/config/cloudconfig/common-units.yaml
envsubst < blacksmith/templates/install-bootstrapper.sh > workspace/config/cloudconfig/install-bootstrapper.sh
envsubst < blacksmith/templates/install-kubernetes-master.sh > workspace/config/cloudconfig/install-kubernetes-master.sh
envsubst < blacksmith/templates/worker-units.yaml > workspace/config/cloudconfig/worker-units.yaml
envsubst < blacksmith/templates/worker.yaml > workspace/config/cloudconfig/worker.yaml

## Certificates
extra_sans=${CERT_ARGS:-}
cert_dir=$(pwd)/workspace/kubernetes/certs

mkdir -p "$cert_dir"
use_cn=false

sans="IP:${BLACKSMITH_BOOTSTRAPPER1_IP},IP:10.100.0.1,DNS:${BLACKSMITH_BOOTSTRAPPER1_HOSTNAME},DNS:${BLACKSMITH_BOOTSTRAPPER1_HOSTNAME}.${CLUSTER_NAME},DNS:kubernetes,DNS:kubernetes.default,DNS:kubernetes.default.svc,DNS:kubernetes.default.svc.kubernetes.local"
if [[ -n "${extra_sans}" ]]; then
  sans="${sans},${extra_sans}"
fi

previous=$(pwd)
cd binaries/easy-rsa-master/easyrsa3

rm -r pki || echo "Not Fatal"
./easyrsa init-pki

./easyrsa --batch "--req-cn=$BLACKSMITH_BOOTSTRAPPER1_IP@`date +%s`" build-ca nopass

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
echo $TOKEN,admin,admin > "${cert_dir}/known_tokens.csv"

cd $previous
mkdir workspace/kubernetes/manifests
envsubst < kubernetes-manifests/apiserver.yaml > workspace/kubernetes/manifests/apiserver.yaml
envsubst < kubernetes-manifests/controller.yaml > workspace/kubernetes/manifests/controller.yaml
envsubst < kubernetes-manifests/scheduler.yaml > workspace/kubernetes/manifests/scheduler.yaml

cp binaries/kubectl workspace/files/
cp binaries/kubelet workspace/files/
cp binaries/kube-proxy workspace/files/

tar -cf workspace.tar workspace
