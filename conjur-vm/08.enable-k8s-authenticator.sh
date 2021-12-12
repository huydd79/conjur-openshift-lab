#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

set -x
conjur -d policy load -f ./policies/authn-k8s-cluster.yaml -b root

docker exec $node_name chpst -u conjur conjur-plugin-service possum rake authn_k8s:ca_init["conjur/authn-k8s/okd"]
docker exec -it $node_name sh -c 'grep -q "authn,authn-k8s/okd" /opt/conjur/etc/conjur.conf || echo "CONJUR_AUTHENTICATORS=\"authn,authn-k8s/okd\"\n">>/opt/conjur/etc/conjur.conf'
docker exec $node_name sv restart conjur
set +x
