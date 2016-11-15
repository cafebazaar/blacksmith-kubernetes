#!/bin/bash

## Installing Blacksmith Docker
if [[ $(docker -H unix:///var/run/early-docker.sock inspect blacksmith) == "[]" ]]; then
  VOLUME_ARGS="-v /var/lib/blacksmith/workspaces:/workspace"
  ARGS="-etcd http://<< (cluster_variable "bootstrapper1_ip") >>:2379,http://<< (cluster_variable "bootstrapper2_ip") >>:2379,http://<< (cluster_variable "bootstrapper3_ip") >>:2379 -if $1 -cluster-name << (cluster_variable "cluster_name") >> -lease-start << (cluster_variable "internal_network_workers_start") >> -lease-range <<(cluster_variable "internal_network_workers_limit")>> -dns << (cluster_variable "external_dns") >> -file-server << (cluster_variable "file_server") >> -workspace-repo git@git.cafebazaar.ir:ali.javadi/blacksmith-kubernetes.git"
  docker -H unix:///var/run/early-docker.sock rm -f blacksmith || true
  docker -H unix:///var/run/early-docker.sock pull << (cluster_variable "blacksmith_image") >>
  docker -H unix:///var/run/early-docker.sock run --name blacksmith --restart=always -d --net=host $VOLUME_ARGS << (cluster_variable "blacksmith_image") >> $ARGS
fi

###############################################################################
## Begin: Hack, until https://github.com/cafebazaar/blacksmith/issues/30 is fixed

etcdctl set "/skydns/<<(cluster_variable "cluster_name")>>/<<(cluster_variable "bootstrapper1_hostname")>>" "{\"host\":\"<< (cluster_variable "bootstrapper1_ip") >>\"}"
etcdctl set "/skydns/<<(cluster_variable "cluster_name")>>/<<(cluster_variable "bootstrapper2_hostname")>>" "{\"host\":\"<< (cluster_variable "bootstrapper2_ip") >>\"}"
etcdctl set "/skydns/<<(cluster_variable "cluster_name")>>/<<(cluster_variable "bootstrapper3_hostname")>>" "{\"host\":\"<< (cluster_variable "bootstrapper3_ip") >>\"}"



etcdctl set "/skydns/<<(cluster_variable "cluster_name")>>/master/<<(cluster_variable "bootstrapper1_hostname")>>" "{\"host\":\"<< (cluster_variable "bootstrapper1_ip") >>\"}"
etcdctl set "/skydns/<<(cluster_variable "cluster_name")>>/master/<<(cluster_variable "bootstrapper2_hostname")>>" "{\"host\":\"<< (cluster_variable "bootstrapper2_ip") >>\"}"
etcdctl set "/skydns/<<(cluster_variable "cluster_name")>>/master/<<(cluster_variable "bootstrapper3_hostname")>>" "{\"host\":\"<< (cluster_variable "bootstrapper3_ip") >>\"}"


## End: Hack, until https://github.com/cafebazaar/blacksmith/issues/30 is fixed
###############################################################################

## Installing SkyDNS
if [[ $(docker -H unix:///var/run/early-docker.sock inspect skydns) == "[]" ]]; then
  docker -H unix:///var/run/early-docker.sock rm -f skydns || true
  docker -H unix:///var/run/early-docker.sock pull << (cluster_variable "skydns_image") >>
  docker -H unix:///var/run/early-docker.sock run --name skydns --restart=always -d --net=host -e ETCD_MACHINES=http://<< (cluster_variable "bootstrapper1_ip") >>:2379,http://<< (cluster_variable "bootstrapper2_ip") >>:2379,http://<< (cluster_variable "bootstrapper3_ip") >>:2379 << (cluster_variable "skydns_image") >>
fi
