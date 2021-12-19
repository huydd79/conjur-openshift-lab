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
oc project $AUTHN_NS

TOKEN_SECRET_NAME="$(oc get secrets -n $AUTHN_NS \
| grep $AUTHN_SA'.*service-account-token' \
| head -n1 \
| awk '{print $1}')"

CA_CERT="$(oc get secret -n $AUTHN_NS $TOKEN_SECRET_NAME -o json \
| jq -r '.data["ca.crt"]' \
| base64 --decode)"

SERVICE_ACCOUNT_TOKEN="$(oc get secret -n $AUTHN_NS $TOKEN_SECRET_NAME -o json \
| jq -r .data.token \
| base64 --decode)"

API_URL="$(oc config view --minify -o json \
| jq -r '.clusters[0].cluster.server')"

conjur variable set -i conjur/authn-k8s/$SERVICE_ID/kubernetes/ca-cert -v "$CA_CERT"
conjur variable set -i conjur/authn-k8s/$SERVICE_ID/kubernetes/service-account-token -v "$SERVICE_ACCOUNT_TOKEN"
conjur variable set -i conjur/authn-k8s/$SERVICE_ID/kubernetes/api-url -v "$API_URL"

set +x
