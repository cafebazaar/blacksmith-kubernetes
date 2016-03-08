#!/bin/bash
export REPO=X


wget $REPO/up/vars/kuber_env.sh
source kuber_env.sh

wget $REPO/blacksmith/blacksmith_variables.sh
source blacksmith_variables.sh

source specific_variables.sh

cd ~
wget $REPO/blacksmith/workspace.tar.gz

mkdir -p $WORKSPACE_CREATION
tar xvfz workspace.tar.gz -C $WORKSPACE_CREATION
sudo chown core:core $WORKSPACE_CREATION/workspace -R
cd $WORKSPACE_CREATION/workspace
sudo chmod +x create.sh
./create.sh
cd ~

sudo chown core:core $WORKSPACE_CREATION/workspace -R

mkdir -p $WORKSPACE_PATH/files/bin

wget $REPO/kubernetes/bin/kubelet -O $WORKSPACE_PATH/$PATH_TO_KUBELET
wget $REPO/kubernetes/bin/kube-proxy -O $WORKSPACE_PATH/$PATH_TO_KUBE_PROXY

wget $REPO/blacksmith/worker_cloud.yaml
wget $REPO/utils/envsubst
sudo chmod +x envsubst
./envsubst < worker_cloud.yaml > $WORKSPACE_PATH/config/cloudconfig/inited.yaml

cp /home/core/.kube/config $WORKSPACE_PATH/$PATH_TO_KUBE_CONFIG


## Installing Blacksmith Docker
int2ip()
{
    local ui32=$1; shift
    local ip n
    for n in 1 2 3 4; do
        ip=$((ui32 & 0xff))${ip:+.}$ip
        ui32=$((ui32 >> 8))
    done
    echo -n $ip
}

netmask()
{
    local mask=$((0xffffffff << (32 - $1))); shift
    int2ip $mask
}

VOLUME_ARGS="-v ${WORKSPACE_PATH}:/workspace"
ARGS="-etcd ${BLACKSMITH_INSTALL_ETCD_ENDPOINTS} -if ${THIS_MACHINE_BLACKSMITH_INTERFACE_NAME} -cluster-name ${CLUSTER_NAME} -lease-start ${INTERNAL_NETWORK_WORKERS_START} -lease-range ${INTERNAL_NETWORK_WORKERS_LIMIT} -lease-subnet $(netmask ${INTERNAL_NETWORK_NETSIZE}) -router ${INTERNAL_NETWORK_GATEWAY_IP} -dns ${EXTERNAL_DNS}"

docker kill -s HUP docker; docker kill blacksmith || echo "NOT FATAL"
docker rm          blacksmith || echo "NOT FATAL"
docker run --name  blacksmith --restart=always --net=host -d $VOLUME_ARGS cafebazaar/blacksmith $ARGS


## Installing SkyDNS
docker kill skydns || echo "NOT FATAL"
docker rm skydns || echo "NOT FATAL"
docker run -d -p 0.0.0.0:53:53/udp --restart=always --name skydns -e ETCD_MACHINES=${BLACKSMITH_INSTALL_ETCD_ENDPOINTS} skynetservices/skydns
