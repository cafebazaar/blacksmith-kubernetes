#!/bin/bash
export REPO=X

export CHANNEL=beta
export WORKSPACE_DIR=workspace

mkdir -p $WORKSPACE_DIR
cp -rp config $WORKSPACE_DIR/
mkdir -p $WORKSPACE_DIR/keyring

export NOW=$(pwd)
cd $WORKSPACE_DIR/keyring; wget -N https://coreos.com/security/image-signing-key/CoreOS_Image_Signing_Key.asc
gpg --no-default-keyring --keyring $WORKSPACE_DIR/keyring/keyring.gpg --import $WORKSPACE_DIR/keyring/CoreOS_Image_Signing_Key.asc
cd $NOW
./_update.sh $WORKSPACE_DIR $CHANNEL
