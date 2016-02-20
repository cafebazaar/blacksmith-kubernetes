#!/bin/bash
export REPO=X


wget $REPO/up/vars/kuber_env.sh
source kuber_env.sh

wget $REPO/blacksmith/blacksmith_variables.sh
source blacksmith_variables.sh

source specific_variables.sh

git clone http://github.com/cafebazaar/blacksmith-workspace-kubernetes

mkdir -p $WORKSPACE_PATH/files/bin

wget $REPO/kubernetes/bin/kubelet -O $WORKSPACE_PATH/$PATH_TO_KUBELET
wget $REPO/kubernetes/bin/kube-proxy -O $WORKSPACE_PATH/$PATH_TO_KUBE_PROXY

wget $REPO/blacksmith/worker_cloud.yaml
wget $REPO/utils/envsubst
sudo chmod +x envsubst
./envsubst < worker_cloud.yaml > $WORKSPACE_PATH/config/cloudconfig/inited.yaml

cp /home/core/.kube/config $WORKSPACE_PATH/$PATH_TO_KUBE_CONFIG

cd $WORKSPACE_PATH
#make
cd ~

git clone https://github.com/cafebazaar/blacksmith
cd blacksmith
sudo ./install-as-docker.sh $WORKSPACE_PATH/workspace ${BLACKSMITH_INSTALL_ETCD_ENDPOINTS} ${THIS_MACHINE_BLACKSMITH_INTERFACE_NAME}
cd ..

