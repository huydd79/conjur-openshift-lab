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
cp conjur-policy-ocp-follower.yml /tmp/conjur-policy-ocp-follower.yml
sed -i "s/FOLLOWER_NS/$FOLLOWER_NS/g" /tmp/conjur-policy-ocp-follower.yml
sed -i "s/FOLLOWER_SA/$FOLLOWER_SA/g" /tmp/conjur-policy-ocp-follower.yml
sed -i "s/FOLLOWER_HOST_ID/$FOLLOWER_HOST_ID/g" /tmp/conjur-policy-ocp-follower.yml
sed -i "s/SERVICE_ID/$SERVICE_ID/g" /tmp/conjur-policy-ocp-follower.yml

conjur -d policy load -f /tmp/conjur-policy-ocp-follower.yml -b root
set +x
