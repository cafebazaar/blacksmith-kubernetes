#!/bin/bash
export REPO=X

sudo wget $REPO/cloud/cloudconfig1.yaml
sudo coreos-install -c cloudconfig1.yaml -d /dev/sda -b $REPO/coreos

sudo reboot
