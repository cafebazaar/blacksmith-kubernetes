#!/bin/bash

echo "Downloading CoreOS Images..."
./download-coreos-images.sh

echo "Downloading Kubernetes..."
./download-kubernetes.sh
