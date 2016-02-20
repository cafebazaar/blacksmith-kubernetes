#!/bin/bash

export PATH_TO_KUBE_PROXY=files/bin/kube-proxy
export PATH_TO_KUBE_CONFIG=files/config
export PATH_TO_KUBELET=files/bin/kubelet
export WORKSPACE_PATH=/home/core/blacksmith-workspace-kubernetes

export BLACKSMITH_INSTALL_ETCD_ENDPOINTS=${BLACKSMITH_MASTER_IP}:2379,${BLACKSMITH_SECOND_IP}:2379,${BLACKSMITH_THIRD_IP}:2379
