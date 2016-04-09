#!/bin/bash

## Installing Blacksmith Docker
if [[ $(docker -H unix:///var/run/early-docker.sock inspect blacksmith) == "[]" ]]; then
  VOLUME_ARGS="-v /var/lib/blacksmith/workspace:/workspace"
  ARGS="-etcd http://$BLACKSMITH_BOOTSTRAPPER1_IP:2379,http://$BLACKSMITH_BOOTSTRAPPER2_IP:2379,http://$BLACKSMITH_BOOTSTRAPPER3_IP:2379 -if ${DOLLAR}1 -cluster-name $CLUSTER_NAME -lease-start $INTERNAL_NETWORK_WORKERS_START -lease-range $INTERNAL_NETWORK_WORKERS_LIMIT -lease-subnet $INTERNAL_NETWORK_NETMASK -router $INTERNAL_NETWORK_GATEWAY_IP -dns $EXTERNAL_DNS"
  docker -H unix:///var/run/early-docker.sock run --name blacksmith --restart=always -d --net=host ${DOLLAR}VOLUME_ARGS cafebazaar/blacksmith ${DOLLAR}ARGS
fi

# wait for blacksmith to be ready
sleep 10

# split hostname over dot
node_name=$(echo $(hostname) | cut -d"." -f1)
cluster_name=$(echo $(hostname) | cut -d"." -f2)

# find the current node's ip address
for ip in $BLACKSMITH_BOOTSTRAPPER1_IP $BLACKSMITH_BOOTSTRAPPER2_IP $BLACKSMITH_BOOTSTRAPPER3_IP
do
    if [ $(ip addr | grep $ip | wc -l) -eq "1" ]
    then
      current_node_ip=$ip
    fi
done

# this node will put it's (name, address) pair in the etcd directory from which skydns resolves hostnames
# if current_node_ip looks like an ip address
if [ $( echo $current_node_ip | grep -o \\. | wc -l) -eq "3" ]
then
  etcdctl set "/skydns/${cluster_name}/${node_name}" "{\"host\":\"$current_node_ip\"}"
fi

## Installing SkyDNS
if [[ $(docker -H unix:///var/run/early-docker.sock inspect skydns) == "[]" ]]; then
  docker -H unix:///var/run/early-docker.sock run --name skydns --restart=always -d -p 0.0.0.0:53:53/udp -e ETCD_MACHINES=http://$BLACKSMITH_BOOTSTRAPPER1_IP:2379,http://$BLACKSMITH_BOOTSTRAPPER2_IP:2379,http://$BLACKSMITH_BOOTSTRAPPER3_IP:2379 skynetservices/skydns
fi
