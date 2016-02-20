#!/bin/bash
export REPO=http://192.168.60.1/blacksmith

wget $REPO/up/vars/kuber_env.sh

wget $REPO/blacksmith/blacksmith_install.sh
sudo chmod +x blacksmith_install.sh 
./blacksmith_install.sh
