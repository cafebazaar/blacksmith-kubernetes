#!/bin/bash

echo "Downloading CoreOS Images..."
./download-coreos-images.sh

echo "Downloading Kubernetes files..."
./download-kubernetes.sh

echo "Downloading easyrsa..."
./download-easyrsa.sh
