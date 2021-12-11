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
eval $(crc oc-env)
eval $(crc console --credentials | grep admin | sed -s "s/.* '\(.*\)'/\1/")
oc project dap

oc apply -f ./seedfetcher/conjur-authenticator-role.yaml
oc apply -f ./seedfetcher/conjur-authenticator-role.yaml
oc apply -f ./seedfetcher/conjur-authenticator-clusterole-binding.yaml

sudo yum install -y jq

TOKEN_SECRET_NAME="$(oc get secrets -n dap \
| grep 'conjur.*service-account-token' \
| head -n1 \
| awk '{print $1}')"

CA_CERT="$(oc get secret -n dap $TOKEN_SECRET_NAME -o json \
| jq -r '.data["ca.crt"]' \
| base64 --decode)"

SERVICE_ACCOUNT_TOKEN="$(oc get secret -n dap $TOKEN_SECRET_NAME -o json \
| jq -r .data.token \
| base64 --decode)"

API_URL="$(oc config view --minify -o json \
| jq -r '.clusters[0].cluster.server')"

conjur variable set -i conjur/authn-k8s/okd/kubernetes/ca-cert -v "$CA_CERT"
conjur variable set -i conjur/authn-k8s/okd/kubernetes/service-account-token -v "$SERVICE_ACCOUNT_TOKEN"
conjur variable set -i conjur/authn-k8s/okd/kubernetes/api-url -v "$API_URL"

set +x
#Doublecheck
