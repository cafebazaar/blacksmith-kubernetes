#!/bin/bash

export DIR=$(pwd)
source $DIR/kuber_env.sh


#manifests
sudo chmod +x bin/*

sudo mkdir -p /srv/kubernetes
sudo chown core:core /srv/kubernetes -R

sudo mkdir -p ${BLACKSMITH_MANIFESTS_DIR}
sudo cp manifests/* ${BLACKSMITH_MANIFESTS_DIR}

sudo mkdir -p ${BLACKSMITH_KUBELET_DIR}
sudo cp bin/kubectl ${BLACKSMITH_KUBECTL_DIR}

sudo mkdir -p /opt/bin
sudo cp bin/kubectl /opt/bin/kubectl

sudo mkdir -p ${BLACKSMITH_KUBELET_DIR}
sudo cp bin/kubelet /opt/bin/kubelet
sudo cp bin/kubelet ${BLACKSMITH_KUBELET_DIR}/kubelet

sudo mkdir -p ${BLACKSMITH_KUBEPROXY_DIR}
sudo cp bin/kube-proxy /opt/bin/kube-proxy
sudo cp bin/kube-proxy ${BLACKSMITH_KUBELET_DIR}/kube-proxy

sudo chown core:core /opt/bin/ -R
sudo chown core:core /opt/kubernetes -R

# certificates
sh certgen.sh $MASTER_IP $CERT_ARGS
export TOKEN=$(dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64 | tr -d "=+/" | dd bs=32 count=1 2>/dev/null)

#should it be $TOKEN,$USER,$USER ?
sudo echo $TOKEN,admin,admin > ${KNOWN_TOKENS}

kubectl config set-cluster $CLUSTER_NAME --certificate-authority=$CA_CERT --embed-certs=true --server=https://$MASTER_IP

kubectl config set-credentials $USER --client-certificate=$CLI_CERT --client-key=$CLI_KEY --embed-certs=true --token=$TOKEN


kubectl config set-context $CONTEXT_NAME --cluster=$CLUSTER_NAME --user=$USER
kubectl config use-context $CONTEXT_NAME
