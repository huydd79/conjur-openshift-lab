#/bin/sh
set -x
conjur -d policy load -f authn-k8s-ocp.yaml -b root
#docker exec conjur1 chpst -u conjur conjur-plugin-service possum rake authn_k8s:ca_init["conjur/authn-k8s/ocp"]
#docker exec -it $node_name sh -c 'grep -q "authn,authn-k8s/ocp" /opt/conjur/etc/conjur.conf || echo "CONJUR_AUTHENTICATORS=\"authn,authn-k8s/ocp\"\n">>/opt/conjur/etc/conjur.conf'
#docker exec $node_name sv restart conjur
set +x
