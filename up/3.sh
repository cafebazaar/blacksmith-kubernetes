#!/bin/bash
export REPO=X

wget $REPO/up/general.sh
wget $REPO/up/vars/variables3.sh -O specific_variables.sh

sudo chmod +x general.sh
sudo chmod +x specific_variables.sh

./general.sh

#get specific variables
