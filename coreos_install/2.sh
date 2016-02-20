#!/bin/bash
export REPO=http://192.168.60.1/blacksmith

sudo wget $REPO/cloud/cloudconfig2.yaml
sudo coreos-install -c cloudconfig2.yaml -d /dev/sda -b $REPO/coreos

sudo reboot
