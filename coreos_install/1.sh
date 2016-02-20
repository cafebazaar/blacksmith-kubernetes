#!/bin/bash
export REPO=http://192.168.60.1/blacksmith

sudo wget $REPO/cloud/cloudconfig1.yaml
sudo coreos-install -c cloudconfig1.yaml -d /dev/sda -b $REPO/coreos

sudo reboot
