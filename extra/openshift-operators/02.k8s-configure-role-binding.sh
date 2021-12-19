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
oc new-project $AUTHN_NS
oc project $AUTHN_NS
oc create serviceaccount $AUTHN_SA -n $AUTHN_NS

cp conjur-authenticator-role.yaml /tmp/conjur-authenticator-role.yaml
sed -i "s/AUTHN_ROLE/$AUTHN_ROLE/g" /tmp/conjur-authenticator-role.yaml

cp conjur-authenticator-clusterole-binding.yaml /tmp/conjur-authenticator-clusterole-binding.yaml
sed -i "s/AUTHN_NS/$AUTHN_NS/g" /tmp/conjur-authenticator-clusterole-binding.yaml
sed -i "s/AUTHN_SA/$AUTHN_SA/g" /tmp/conjur-authenticator-clusterole-binding.yaml
sed -i "s/AUTHN_ROLE/$AUTHN_ROLE/g" /tmp/conjur-authenticator-clusterole-binding.yaml

oc apply -f /tmp/conjur-authenticator-role.yaml
oc apply -f /tmp/conjur-authenticator-clusterole-binding.yaml

set +x
