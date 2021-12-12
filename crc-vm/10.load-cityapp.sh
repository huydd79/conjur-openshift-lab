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

count=$(docker images -a | grep -c cityapp)
if [[ $count == 0 ]]; then
    cd ./cityapp/build
    set -euo pipefail
    sudo docker build -t cityapp:1.0 .
    docker save cityapp -o /tmp/cityapp-1.0.tgz
    docker rmi -f $(docker images -a | grep cityapp | awk '{print $3}')
    docker rmi $(docker images --filter "dangling=true" -q --no-trunc)
    docker rmi -f $(docker images -a | grep alpine | awk '{print $3}')
    docker load -i /tmp/cityapp-1.0.tgz
fi

eval $(crc oc-env)
eval $(crc console --credentials | grep admin | sed -s "s/.* '\(.*\)'/\1/")   #'
crchost=default-route-openshift-image-registry.apps-crc.testing
oc new-project cityapp
docker login -u _ -p $(oc whoami -t) $crchost
docker tag cityapp:1.0 $crchost/cityapp/cityapp
docker push $crchost/cityapp/cityapp
set +x
