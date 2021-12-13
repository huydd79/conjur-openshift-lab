#!/bin/sh

#Change your configuration and set READY=true when done
READY=false

#IP addresses of conjur and crc VM
CONJUR_IP=172.16.100.61
CRC_IP=172.16.100.62
LAB_DOMAIN=demo.local
LAB_CONJUR_ADMIN_PW=ChangeMe123!
LAB_CONJUR_ACCOUNT=DEMO
#Path to folder with all docker images
UPLOAD_DIR=/opt/lab/setup_files
conjur_appliance_file=conjur-appliance_12.4.0.tar.gz
conjur_version=12.4.0
#Conjur container name
node_name=conjur1

