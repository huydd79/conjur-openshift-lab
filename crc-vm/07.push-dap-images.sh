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
docker load -i $UPLOAD_DIR/$conjur_appliance_file
docker load -i $UPLOAD_DIR/$dap_seedfetcher_file
dnsname=default-route-openshift-image-registry.apps-crc.testing
sudo mkdir -p /etc/docker/certs.d/$dnsname
openssl s_client -showcerts -connect $dnsname:443 -servername $dnsname \
    </dev/null | sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' \
    > /tmp/ca.crt
sudo mv /tmp/ca.crt /etc/docker/certs.d/$dnsname/ca.crt
eval $(crc oc-env)
eval $(crc console --credentials | grep admin | sed -s "s/.* '\(.*\)'/\1/")   #'
docker login -u _ -p $(oc whoami -t) $dnsname
oc new-project dap
oc create serviceaccount conjur-cluster -n dap
oc adm policy add-scc-to-user anyuid "system:serviceaccount:dap:conjur-cluster"

conjur_version=$(docker images -a | grep registry.tld/conjur-appliance | awk '{print $2}')
seedfetcher_version=$(docker images -a | grep cyberark/dap-seedfetcher | awk '{print $2}')

docker tag registry.tld/conjur-appliance:$conjur_version $dnsname/dap/conjur-appliance
docker tag cyberark/dap-seedfetcher:$seedfetcher_version $dnsname/dap/dap-seedfetcher

docker push $dnsname/dap/conjur-appliance
docker push $dnsname/dap/dap-seedfetcher
set +x
#Doublecheck
oc get is
