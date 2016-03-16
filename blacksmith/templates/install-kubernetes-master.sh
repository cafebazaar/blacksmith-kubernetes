#!/bin/bash

#installing kubernetes
if [ ! -f /home/core/.kube/config]; then
    groupadd kube-cert || echo "group already exist"

    mkdir -p /srv/kubernetes
    cp /var/lib/blacksmith/workspace/kubernetes/certs/* /srv/kubernetes
    chown core:core /srv/kubernetes -R
    chgrp kube-cert /srv/kubernetes/server.key /srv/kubernetes/server.cert /srv/kubernetes/ca.crt
    chmod 660 /srv/kubernetes/server.key /srv/kubernetes/server.cert /srv/kubernetes/ca.crt

    mkdir -p /opt/kubernetes/manifests
    cp /var/lib/blacksmith/workspace/kubernetes/manifests/* /opt/kubernetes/manifests
    chown core:core /opt/kubernetes -R

    mkdir -p /opt/bin
    cp /var/lib/blacksmith/workspace/files/kubectl /opt/bin/
    cp /var/lib/blacksmith/workspace/files/kubelet /opt/bin/
    cp /var/lib/blacksmith/workspace/files/kube-proxy /opt/bin/
    chown core:core /opt/bin/ -R

    /opt/bin/kubectl config set-cluster $CLUSTER_NAME --certificate-authority=$CA_CERT --embed-certs=true --server=https://$MASTER_IP
    /opt/bin/kubectl config set-credentials $USER --client-certificate=$CLI_CERT --client-key=$CLI_KEY --embed-certs=true --token=$KUBERNETES_TOKEN
    /opt/bin/kubectl config set-context $CONTEXT_NAME --cluster=$CLUSTER_NAME --user=$USER
    /opt/bin/kubectl config use-context $CONTEXT_NAME
fi
