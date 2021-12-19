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
oc new-project $FOLLOWER_NS
oc project $FOLLOWER_NS

openssl s_client -showcerts \
    -connect conjur-master.$LAB_DOMAIN:443 \
    -servername conjur-master.$LAB_DOMAIN </dev/null 2>/dev/null | \
    sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > \
    /tmp/master-certificate.pem

oc create configmap conjur.master-cert \
    --from-file=conjur.master-cert=<(cat /tmp/master-certificate.pem)
set +x
