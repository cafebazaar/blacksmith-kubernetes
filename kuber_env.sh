#!/bin/bash


export CLUSTER_NAME=cafecluster

export BLACKSMITH_KUBECONFIG_DIR=/home/core/.kube

export BLACKSMITH_ETCD_CLUSTER_TOKEN=local_kuber
export BLACKSMITH_KUBELET_DIR=/opt/kubernetes/bin
export BLACKSMITH_KUBECTL_DIR=/opt/kubernetes/bin
export BLACKSMITH_MANIFESTS_DIR=/opt/kubernetes/manifests

export BLACKSMITH_KUBEPROXY_DIR=/opt/kubernetes/bin

export BLACKSMITH_BOOTSTRAPPER1_HOSTNAME=bootstrapper1
export BLACKSMITH_BOOTSTRAPPER1_IP=192.168.64.11
export BLACKSMITH_BOOTSTRAPPER1_INTERNAL_INTERFACE_NAME=eno1

export BLACKSMITH_BOOTSTRAPPER2_IP=192.168.64.12
export BLACKSMITH_BOOTSTRAPPER2_INTERNAL_INTERFACE_NAME=eno1

export BLACKSMITH_BOOTSTRAPPER3_IP=192.168.64.13
export BLACKSMITH_BOOTSTRAPPER3_INTERNAL_INTERFACE_NAME=eno1

export INTERNAL_NETWORK_GATEWAY_IP=192.168.64.1
export INTERNAL_NETWORK_NETSIZE=20
export EXTERNAL_DNS=8.8.8.8
export INTERNAL_NETWORK_WORKERS_START=192.168.65.1
export INTERNAL_NETWORK_WORKERS_LIMIT=3580

export POD_NETWORK=10.1.0.0/16
export SERVICE_IP_RANGE=10.100.0.0/16
export K8S_SERVICE_IP=10.100.0.1
export DNS_SERVICE_IP=10.100.0.10

export MASTER_IP=$BLACKSMITH_BOOTSTRAPPER1_IP

export CERT_ARGS=IP:10.100.0.1,IP:${MASTER_IP},DNS:${BLACKSMITH_BOOTSTRAPPER1_HOSTNAME},DNS:${BLACKSMITH_BOOTSTRAPPER1_HOSTNAME}.${CLUSTER_NAME},DNS:kubernetes,DNS:kubernetes.default,DNS:kubernetes.default.svc,DNS:kubernetes.default.svc.kubernetes.local

export USER=admin
export CA_CERT=/srv/kubernetes/ca.crt
export MASTER_KEY=/srv/kubernetes/server.key
export MASTER_CERT=/srv/kubernetes/server.cert
export KUBELET_KEY=/srv/kubernetes/kubelet.key
export KUBELET_CERT=/srv/kubernetes/kubelet.crt

export CLI_CERT=/srv/kubernetes/kubecfg.crt
export CLI_KEY=/srv/kubernetes/kubecfg.key
export CONTEXT_NAME=default-context

export BLACKSMITH_HYPERKUBE_IMAGE=colonelmo/hyperkube

export KNOWN_TOKENS=/srv/kubernetes/known_tokens.csv
