#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

set -x
docker load -i $UPLOAD_DIR/conjur-appliance_12.4.0.tar.gz
set +x