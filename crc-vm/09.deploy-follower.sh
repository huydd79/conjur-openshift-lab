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
oc project dap
openssl s_client -showcerts \
    -connect conjur-master.$LAB_DOMAIN:443 \
    -servername conjur-master.$LAB_DOMAIN </dev/null | \
    sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > \
    /tmp/master-certificate.pem
oc create configmap master-certificate \
    --from-file=ssl-certificate=<(cat /tmp/master-certificate.pem)
cp ./seedfetcher/follower-dap-with-seedfetcher.yaml /tmp/follower-dap-with-seedfetcher.yaml
sed -i "s/LAB_CONJUR_ACCOUNT/$LAB_CONJUR_ACCOUNT/g" /tmp/follower-dap-with-seedfetcher.yaml
sed -i "s/LAB_DOMAIN/$LAB_DOMAIN/g" /tmp/follower-dap-with-seedfetcher.yaml
oc apply -f /tmp/follower-dap-with-seedfetcher.yaml
set +x
