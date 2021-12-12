#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

set -x
docker stop $node_name
docker container rm $(docker ps -a | grep $node_name | awk '{print $1}')
docker run --name $node_name \
  -d --restart=always \
  --dns $CONJUR_IP \
  -p "443:443" -p "636:636" -p "5432:5432" -p "1999:1999" \
  --security-opt seccomp:unconfined \
  -v /var/log/conjur/$node_name:/var/log/conjur/:Z \
  --log-driver json-file \
  --log-opt max-size=1000m \
  --log-opt max-file=3 \
  registry.tld/conjur-appliance:$conjur_version
set +x