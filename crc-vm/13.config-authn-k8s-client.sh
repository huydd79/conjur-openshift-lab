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
crchost=default-route-openshift-image-registry.apps-crc.testing
docker login -u _ -p $(oc whoami -t) $crchost
docker load -i $UPLOAD_DIR/$conjur_authn_k8s_client_file
version=$(docker images -a | grep cyberark/conjur-authn-k8s-client | awk '{print $2}')
docker tag cyberark/conjur-authn-k8s-client:$version $crchost/cityapp/conjur-authn-k8s-client
docker push $crchost/cityapp/conjur-authn-k8s-client

conjur -d policy load -f ./cityapp/cityapp-summon-init/projects-authn.yaml -b root
conjur -d policy load -f ./cityapp/cityapp-summon-init/app-identity.yaml -b root
conjur -d policy load -f ./cityapp/cityapp-summon-init/safe-permission.yaml -b root

openssl s_client -showcerts -connect follower-dap.apps-crc.testing:443 \
    -servername follower-dap.apps-crc.testing </dev/null | \
    sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > follower-certificate.pem
oc create configmap follower-certificate --from-file=ssl-certificate=<(cat follower-certificate.pem)
oc create configmap cityapp-summon-init-config --from-file=./cityapp/cityapp-summon-init/secrets.yaml
set +x
