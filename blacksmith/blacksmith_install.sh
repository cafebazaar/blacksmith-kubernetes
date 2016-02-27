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


git clone https://github.com/cafebazaar/blacksmith
cd blacksmith
sudo ./install-as-docker.sh $WORKSPACE_PATH ${BLACKSMITH_INSTALL_ETCD_ENDPOINTS} ${THIS_MACHINE_BLACKSMITH_INTERFACE_NAME}
cd ..
