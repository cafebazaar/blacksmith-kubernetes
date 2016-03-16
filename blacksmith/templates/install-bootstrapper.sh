#!/bin/bash

## Installing Blacksmith Docker
if [[ $(docker inspect blacksmith) == "[]" ]]; then
  VOLUME_ARGS="-v /var/lib/blacksmith/workspace:/workspace"
  ARGS="-etcd http://$BLACKSMITH_BOOTSTRAPPER1_IP:2379,http://$BLACKSMITH_BOOTSTRAPPER2_IP:2379,http://$BLACKSMITH_BOOTSTRAPPER3_IP:2379 -if ${DOLLAR}1 -cluster-name $CLUSTER_NAME -lease-start $INTERNAL_NETWORK_WORKERS_START -lease-range $INTERNAL_NETWORK_WORKERS_LIMIT -lease-subnet $INTERNAL_NETWORK_NETMASK -router $INTERNAL_NETWORK_GATEWAY_IP -dns $EXTERNAL_DNS"
  docker run --name blacksmith --restart=always -d --net=host ${DOLLAR}VOLUME_ARGS cafebazaar/blacksmith ${DOLLAR}ARGS
fi

## Installing SkyDNS
if [[ $(docker inspect skydns) == "[]" ]]; then
  docker run --name skydns --restart=always -d -p 0.0.0.0:53:53/udp -e ETCD_MACHINES=http://$BLACKSMITH_BOOTSTRAPPER1_IP:2379,http://$BLACKSMITH_BOOTSTRAPPER2_IP:2379,http://$BLACKSMITH_BOOTSTRAPPER3_IP:2379 skynetservices/skydns
fi
