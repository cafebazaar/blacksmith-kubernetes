#!/bin/bash


export CLUSTER_NAME=cafecluster


# Bootstrapper and Master
export BLACKSMITH_BOOTSTRAPPER1_HOSTNAME=bootstrapper1
export BLACKSMITH_BOOTSTRAPPER1_IP=172.19.1.11

# Bootstrapper but Worker
export BLACKSMITH_BOOTSTRAPPER2_HOSTNAME=bootstrapper2
export BLACKSMITH_BOOTSTRAPPER2_IP=172.19.1.12

# Bootstrapper but Worker
export BLACKSMITH_BOOTSTRAPPER3_HOSTNAME=bootstrapper3
export BLACKSMITH_BOOTSTRAPPER3_IP=172.19.1.13

export INTERNAL_INTERFACE_NAME=eno1
export EXTERNAL_INTERFACE_NAME=eno2

#export INTERNAL_NETWORK_GATEWAY_IP=172.19.1.1
export INTERNAL_NETWORK_NETSIZE=24
export EXTERNAL_DNS=8.8.8.8
export INTERNAL_NETWORK_WORKERS_START=172.19.1.21
export INTERNAL_NETWORK_WORKERS_LIMIT=107

export POD_NETWORK=10.1.0.0/16
export SERVICE_IP_RANGE=10.100.0.0/16
export K8S_SERVICE_IP=10.100.0.1
export DNS_SERVICE_IP=10.100.0.10

export CERT_ARGS=

export CONTEXT_NAME=default-context

export K8S_VER=v1.2.4_coreos.1
export HYPERKUBE_IMAGE=quay.io/coreos/hyperkube:$K8S_VER
export BLACKSMITH_IMAGE=cafebazaar/blacksmith:v0.9.1
export SKYDNS_IMAGE=quay.io/cafebazaar/skydns:2.5.3a-42-gc4d7e3d

export ADMIN_PKCS12_PASSWORD=ChangeMe

export CONTAINER_HTTP_PROXY=
export CONTAINER_HTTPS_PROXY=
export "CONTAINER_NO_PROXY=localhost,127.0.0.1,.$CLUSTER_NAME,$BLACKSMITH_BOOTSTRAPPER1_IP,$BLACKSMITH_BOOTSTRAPPER2_IP,$BLACKSMITH_BOOTSTRAPPER3_IP"
