#!/bin/bash

#installing kubernetes
if [ ! -f /home/core/.kube/config]; then
    sudo groupadd kube-cert || echo "group already exist"

    cert_dir=/srv/kubernetes
    cert_group=kube-cert
    sudo chown core:core $cert_dir
    sudo chgrp $cert_group "${cert_dir}/server.key" "${cert_dir}/server.cert" "${cert_dir}/ca.crt"
    sudo chmod 660 "${cert_dir}/server.key" "${cert_dir}/server.cert" "${cert_dir}/ca.crt"

    sudo chown core:core /srv/kubernetes -R
    sudo cp manifests/* ${BLACKSMITH_MANIFESTS_DIR}
    sudo cp bin/kubectl ${BLACKSMITH_KUBECTL_DIR}
    sudo cp bin/kubectl /opt/bin/kubectl
    sudo cp bin/kubelet /opt/bin/kubelet
    sudo cp bin/kubelet ${BLACKSMITH_KUBELET_DIR}/kubelet
    sudo cp bin/kube-proxy /opt/bin/kube-proxy
    sudo cp bin/kube-proxy ${BLACKSMITH_KUBELET_DIR}/kube-proxy

    sudo chown core:core /opt/bin/ -R
    sudo chown core:core /opt/kubernetes -R

    export TOKEN=$(dd if=/dev/urandom bs=128 count=1 2>/dev/null | base64 | tr -d "=+/" | dd bs=32 count=1 2>/dev/null)

    #should it be $TOKEN,$USER,$USER ?
    sudo echo $TOKEN,admin,admin > ${KNOWN_TOKENS}
    #kubectl in path?
    kubectl config set-cluster $CLUSTER_NAME --certificate-authority=$CA_CERT --embed-certs=true --server=https://$MASTER_IP

    kubectl config set-credentials $USER --client-certificate=$CLI_CERT --client-key=$CLI_KEY --embed-certs=true --token=$TOKEN

    kubectl config set-context $CONTEXT_NAME --cluster=$CLUSTER_NAME --user=$USER
    kubectl config use-context $CONTEXT_NAME
fi
