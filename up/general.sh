#!/bin/bash
export REPO=X

wget $REPO/up/vars/kuber_env.sh

wget $REPO/blacksmith/blacksmith_install.sh
sudo chmod +x blacksmith_install.sh 
./blacksmith_install.sh
