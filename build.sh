#!/bin/bash
set -e

# Variables are injected from this configuration file:
export DOLLAR='$'
source config.sh
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

project_root=$(pwd)

#### Clean ###################################################################
rm -rf workspace/*
rm -rf Takeaways/*

#### BoB Workspace ###########################################################
mkdir -p workspace/files

cp -r binaries/images workspace/
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
envsubst < blacksmith/templates/flannel-options.env > workspace/config/cloudconfig/flannel-options.env
envsubst < blacksmith/templates/install-bootstrapper.sh > workspace/config/cloudconfig/install-bootstrapper.sh
envsubst < blacksmith/templates/master-units.yaml > workspace/config/cloudconfig/master-units.yaml
envsubst < blacksmith/templates/worker.yaml > workspace/config/cloudconfig/worker.yaml

envsubst < blacksmith/templates/kubernetes-manifests/kube-apiserver.yaml > workspace/config/cloudconfig/kube-apiserver.yaml
envsubst < blacksmith/templates/kubernetes-manifests/kube-controller-manager.yaml > workspace/config/cloudconfig/kube-controller-manager.yaml
envsubst < blacksmith/templates/kubernetes-manifests/kube-proxy.yaml > workspace/config/cloudconfig/kube-proxy.yaml
envsubst < blacksmith/templates/kubernetes-manifests/kube-proxy-worker.yaml > workspace/config/cloudconfig/kube-proxy-worker.yaml
envsubst < blacksmith/templates/kubernetes-manifests/kube-scheduler.yaml > workspace/config/cloudconfig/kube-scheduler.yaml

cp binaries/initial.yaml workspace/
echo "net-conf: '$INTERNAL_NET_CONF'" >> workspace/initial.yaml

#### Certificates ############################################################
extra_sans=${CERT_ARGS:-}
cert_dir=$project_root/workspace/config/cloudconfig

sans="IP:${BLACKSMITH_BOOTSTRAPPER1_IP},IP:${BLACKSMITH_BOOTSTRAPPER2_IP},IP:${BLACKSMITH_BOOTSTRAPPER3_IP},IP:10.100.0.1,DNS:${BLACKSMITH_BOOTSTRAPPER1_HOSTNAME},DNS:${BLACKSMITH_BOOTSTRAPPER1_HOSTNAME}.${CLUSTER_NAME},DNS:kubernetes,DNS:kubernetes.default,DNS:kubernetes.default.svc,DNS:kubernetes.default.svc.${CLUSTER_NAME},DNS:master.${CLUSTER_NAME}"
if [[ -n "${extra_sans}" ]]; then
  sans="${sans},${extra_sans}"
fi

easyrsa3_dir=$project_root/binaries/easy-rsa-master/easyrsa3

if [ -d "$easyrsa3_dir/pki" ]; then
  echo
  echo "Skipping the key/certificate generation part."
  echo "There's already a pki folder inside $easyrsa3_dir"
  echo
else
  cd $easyrsa3_dir
  ./easyrsa init-pki

  # CA
  ./easyrsa --batch "--req-cn=$BLACKSMITH_BOOTSTRAPPER1_IP@`date +%s`" build-ca nopass

  # Master
  ./easyrsa --subject-alt-name="${sans}" build-server-full kubernetes-master nopass

  # Machines
  ./easyrsa build-client-full machine nopass

  # Admin
  ./easyrsa build-client-full admin nopass
  cd $project_root
fi

cp -p $easyrsa3_dir/pki/ca.crt ${cert_dir}/ca.pem
cp -p $easyrsa3_dir/pki/issued/kubernetes-master.crt "${cert_dir}/apiserver.pem"
cp -p $easyrsa3_dir/pki/private/kubernetes-master.key "${cert_dir}/apiserver-key.pem"

# Creating kube config for machines
wkubeconfig=workspace/config/cloudconfig/worker-kubeconfig.yaml
./binaries/kubectl config --kubeconfig $wkubeconfig set-cluster $CLUSTER_NAME --certificate-authority=${cert_dir}/ca.pem --embed-certs=true --server=https://${K8S_LB_DNS}:4443
./binaries/kubectl config --kubeconfig $wkubeconfig set-credentials machine --client-certificate=$easyrsa3_dir/pki/issued/machine.crt --client-key=$easyrsa3_dir/pki/private/machine.key --embed-certs=true
./binaries/kubectl config --kubeconfig $wkubeconfig set-context $CONTEXT_NAME --cluster=$CLUSTER_NAME --user=machine
./binaries/kubectl config --kubeconfig $wkubeconfig use-context $CONTEXT_NAME

# Takeaways, for humans
mkdir -p $project_root/Takeaways
cp -p $easyrsa3_dir/pki/ca.crt Takeaways/ca.pem
cp -p $easyrsa3_dir/pki/private/ca.key Takeaways/ca.key
envsubst < after-deploy/dns-addon.yml > Takeaways/dns-addon.yml

# Creating kube config for admin
lkubeconfig=Takeaways/kubeconfig
./binaries/kubectl config --kubeconfig $lkubeconfig set-cluster $CLUSTER_NAME --certificate-authority=${cert_dir}/ca.pem --embed-certs=true --server=https://${K8S_LB_DNS}:4443
./binaries/kubectl config --kubeconfig $lkubeconfig set-credentials admin --client-certificate=$easyrsa3_dir/pki/issued/admin.crt --client-key=$easyrsa3_dir/pki/private/admin.key --embed-certs=true
./binaries/kubectl config --kubeconfig $lkubeconfig set-context $CONTEXT_NAME --cluster=$CLUSTER_NAME --user=admin
./binaries/kubectl config --kubeconfig $lkubeconfig use-context $CONTEXT_NAME

ADMIN_CERT_PEM=$(openssl x509 -in $easyrsa3_dir/pki/issued/admin.crt)
ADMIN_KEY_PEM=$(cat $easyrsa3_dir/pki/private/admin.key)
export ADMIN_PKCS12_PASSWORD
echo -e "$ADMIN_KEY_PEM\n$ADMIN_CERT_PEM" | openssl pkcs12 -export -password env:ADMIN_PKCS12_PASSWORD -name "Kube Admin" -out Takeaways/admin.pfx
unset ADMIN_PKCS12_PASSWORD

# We need a Blacksmith-to-Blacksmith sync mechanism
# Hack for now:
tar -cf workspace.tar workspace
mv workspace.tar workspace/files/

echo
