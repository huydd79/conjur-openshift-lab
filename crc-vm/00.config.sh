#!/bin/sh

#Change your configuration and set READY=true when done
READY=true

#IP addresses of conjur and crc VM
CONJUR_IP=10.0.0.100
CRC_IP=10.0.0.101
LAB_DOMAIN=demo.local
LAB_CONJUR_ACCOUNT=DEMO

#Path to folder with all docker images
UPLOAD_DIR=/opt/lab/setup_files
crc_zip_file=crc-linux-amd64.tar.xz
pull_secret_file=pull-secret.txt
conjur_appliance_file=conjur-appliance_12.4.0.tar.gz
conjur_authn_k8s_client_file=conjur-authn-k8s-client_0.22.0.tar.gz
dap_seedfetcher_file=dap-seedfetcher_0.3.1.tar.gz
secretless_broker_file=secretless-broker_1.7.8.tar.gz

