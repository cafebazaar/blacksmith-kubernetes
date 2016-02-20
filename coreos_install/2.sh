#!/bin/bash
export REPO=X

sudo wget $REPO/cloud/cloudconfig2.yaml
sudo coreos-install -c cloudconfig2.yaml -d /dev/sda -b $REPO/coreos

sudo reboot
