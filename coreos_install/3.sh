#!/bin/bash
export REPO=X

sudo wget $REPO/cloud/cloudconfig3.yaml
sudo coreos-install -c cloudconfig3.yaml -d /dev/sda -b $REPO/coreos

sudo reboot
