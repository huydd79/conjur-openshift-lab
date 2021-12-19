#/bin/sh
#/bin/sh
source 00.config.sh

if [[ "$READY" != true ]]; then
    echo "Your configuration are not ready. Set READY=true in 00.config.sh when you are done"
    exit
fi

set -x
conjur init -u https://$CONJUR_HOST.$LAB_DOMAIN
conjur login -i admin
set +x
conjur whoami
