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

authn_name=authn-k8s/$SERVICE_ID
set -x
cp conjur-policy-authn-k8s.yml /tmp/conjur-policy-authn-k8s.yml
sed -i "s/SERVICE_ID/$SERVICE_ID/g" /tmp/conjur-policy-authn-k8s.yml
conjur -d policy load -f /tmp/conjur-policy-authn-k8s.yml -b root

echo "Connecting to conjur host to add configuration. Please enter conjur host's root password..."
ssh root@$CONJUR_HOST node_name="$NODE_NAME" authn_name="$authn_name" bash -s  << 'EOF'
    docker exec $node_name chpst -u conjur conjur-plugin-service possum rake authn_k8s:ca_init["conjur/$authn_name"];
    cfg_file=/opt/conjur/etc/conjur.conf
    methods=`docker exec $node_name cat $cfg_file | grep CONJUR_AUTHENTICATORS | sed -e 's/CONJUR_AUTHENTICATORS="\(.*\)"/\1/'`
    [[ "$methods" = "" ]] && methods="authn"
    echo $methods | grep -q $authn_name || {
	methods="$methods,$authn_name";
	docker exec $node_name grep -v CONJUR_AUTHENTICATORS $cfg_file >/tmp/conjur.conf
	echo "CONJUR_AUTHENTICATORS=\"$methods\"">>/tmp/conjur.conf
	docker exec $node_name mv $cfg_file "$cfg_file.bak"
	docker cp /tmp/conjur.conf $node_name:$cfg_file
    } && {
	echo "Authn name $authn_name had been configured. Please doublecheck file $cfg_file in $node_name container."
    }
    docker exec $node_name sv restart conjur
EOF
set +x
