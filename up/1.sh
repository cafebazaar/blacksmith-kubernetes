#!/bin/bash
export REPO=X

wget $REPO/up/vars/variables1.sh -O specific_variables.sh

wget $REPO/kubernetes/initiate_master.sh
sudo chmod +x initiate_master.sh
./initiate_master.sh

wget $REPO/blacksmith/blacksmith_install.sh
sudo chmod +x blacksmith_install.sh 
./blacksmith_install.sh

