#!/bin/bash

export PATH_TO_KUBE_PROXY=files/bin/kube-proxy
export PATH_TO_KUBE_CONFIG=files/config
export PATH_TO_KUBELET=files/bin/kubelet

export WORKSPACE_CREATION=/home/core
export WORKSPACE_PATH=${WORKSPACE_CREATION}/workspace/workspace

export BLACKSMITH_INSTALL_ETCD_ENDPOINTS=http://${BLACKSMITH_MASTER_IP}:2379,http://${BLACKSMITH_SECOND_IP}:2379,http://${BLACKSMITH_THIRD_IP}:2379
