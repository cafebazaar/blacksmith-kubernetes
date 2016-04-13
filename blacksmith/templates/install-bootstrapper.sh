#!/bin/bash

## Installing Blacksmith Docker
if [[ $(docker -H unix:///var/run/early-docker.sock inspect blacksmith) == "[]" ]]; then
  VOLUME_ARGS="-v /var/lib/blacksmith/workspace:/workspace"
  ARGS="-etcd http://$BLACKSMITH_BOOTSTRAPPER1_IP:2379,http://$BLACKSMITH_BOOTSTRAPPER2_IP:2379,http://$BLACKSMITH_BOOTSTRAPPER3_IP:2379 -if ${DOLLAR}1 -cluster-name $CLUSTER_NAME -lease-start $INTERNAL_NETWORK_WORKERS_START -lease-range $INTERNAL_NETWORK_WORKERS_LIMIT -lease-subnet $INTERNAL_NETWORK_NETMASK -router $INTERNAL_NETWORK_GATEWAY_IP -dns $EXTERNAL_DNS"
  docker -H unix:///var/run/early-docker.sock pull cafebazaar/blacksmith
  docker -H unix:///var/run/early-docker.sock run --name blacksmith --restart=always -d --net=host ${DOLLAR}VOLUME_ARGS cafebazaar/blacksmith ${DOLLAR}ARGS
fi

# Wait for blacksmith to be ready
sleep 60

###############################################################################
## Begin: Hack, until https://github.com/cafebazaar/blacksmith/issues/30 is fixed

etcdctl set "/skydns/${CLUSTER_NAME}/${BLACKSMITH_BOOTSTRAPPER1_HOSTNAME}" "{\"host\":\"$BLACKSMITH_BOOTSTRAPPER1_IP\"}"
etcdctl set "/skydns/${CLUSTER_NAME}/${BLACKSMITH_BOOTSTRAPPER2_HOSTNAME}" "{\"host\":\"$BLACKSMITH_BOOTSTRAPPER2_IP\"}"
etcdctl set "/skydns/${CLUSTER_NAME}/${BLACKSMITH_BOOTSTRAPPER3_HOSTNAME}" "{\"host\":\"$BLACKSMITH_BOOTSTRAPPER3_IP\"}"

## End: Hack, until https://github.com/cafebazaar/blacksmith/issues/30 is fixed
###############################################################################

# Wait for ???
sleep 60

## Installing SkyDNS
if [[ $(docker -H unix:///var/run/early-docker.sock inspect skydns) == "[]" ]]; then
  docker -H unix:///var/run/early-docker.sock pull skynetservices/skydns
  docker -H unix:///var/run/early-docker.sock run --name skydns --restart=always -d --net=host -e ETCD_MACHINES=http://$BLACKSMITH_BOOTSTRAPPER1_IP:2379,http://$BLACKSMITH_BOOTSTRAPPER2_IP:2379,http://$BLACKSMITH_BOOTSTRAPPER3_IP:2379 skynetservices/skydns
fi
