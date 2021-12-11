#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

set -x
masterContainer=$node_name
serverType="master"
masterDNS="conjur-master.cyberarkdemo.local"
clusterDNS="conjur-master.cyberarkdemo.local"
standby1DNS="$node_name.cyberarkdemo.local"
adminPass="CyberArk123!"
accountName="DEMO"
docker exec $masterContainer evoke configure $serverType \
    --accept-eula -h $masterDNS \
    --master-altnames "$clusterDNS,$standby1DNS" \
    -p $adminPass $accountName
set +x