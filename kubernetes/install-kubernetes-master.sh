#!/bin/bash

#installing kubernetes
if [ ! -f /home/core/.kube/config]; then
    sudo groupadd kube-cert || echo "group already exist"

    cert_dir=/srv/kubernetes
    cert_group=kube-cert
    sudo chown core:core $cert_dir
    sudo chgrp $cert_group "${cert_dir}/server.key" "${cert_dir}/server.cert" "${cert_dir}/ca.crt"
    sudo chmod 660 "${cert_dir}/server.key" "${cert_dir}/server.cert" "${cert_dir}/ca.crt"

fi
