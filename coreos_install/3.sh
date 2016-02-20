#!/bin/bash
export REPO=http://192.168.60.1/blacksmith

sudo wget $REPO/cloud/cloudconfig3.yaml
sudo coreos-install -c cloudconfig3.yaml -d /dev/sda -b $REPO/coreos

sudo reboot
