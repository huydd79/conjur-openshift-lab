#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

#Checking if running as root
if [[ "$(whoami)" == "root" ]]; then
    echo "Those scripts can not be run as root!"
    exit
fi

set -x
sudo curl -s -LOJ https://github.com/cyberark/conjur-api-python3/releases/download/v7.0.1/conjur-cli-rhel-8.tar.gz
sudo tar xvf conjur-cli-rhel-8.tar.gz
sudo chmod 755 ./conjur
sudo cp ./conjur /usr/local/bin
conjur init -u https://conjur-master.$LAB_DOMAIN
conjur login -i admin
set +x
#Doublecheck
conjur whoami
