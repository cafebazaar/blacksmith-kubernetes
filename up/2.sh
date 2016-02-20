#!/bin/bash
export REPO=http://192.168.60.1/blacksmith

wget $REPO/up/general.sh
wget $REPO/up/vars/variables2.sh -O specific_variables.sh

sudo chmod +x general.sh
sudo chmod +x specific_variables.sh

./general.sh


#get specific variables
