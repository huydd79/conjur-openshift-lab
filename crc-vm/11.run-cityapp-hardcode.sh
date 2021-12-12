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
eval $(crc oc-env)
eval $(crc console --credentials | grep admin | sed -s "s/.* '\(.*\)'/\1/")   #'
oc project cityapp
cp ./cityapp/cityapp-hardcode/cityapp-hardcode.yaml /tmp/cityapp-hardcode.yaml
sed -i "s/LAB_DOMAIN/$LAB_DOMAIN/g" /tmp/cityapp-hardcode.yaml
oc apply -f /tmp/cityapp-hardcode.yaml
set +x
