#/bin/sh
set -x
TOKEN_SECRET_NAME="$(oc get secrets -n dap1 \
| grep 'conjur.*service-account-token' \
| head -n1 \
| awk '{print $1}')"

CA_CERT="$(oc get secret -n dap1 $TOKEN_SECRET_NAME -o json \
| jq -r '.data["ca.crt"]' \
| base64 --decode)"

SERVICE_ACCOUNT_TOKEN="$(oc get secret -n dap1 $TOKEN_SECRET_NAME -o json \
| jq -r .data.token \
| base64 --decode)"

API_URL="$(oc config view --minify -o json \
| jq -r '.clusters[0].cluster.server')"

conjur variable set -i conjur/authn-k8s/ocp/kubernetes/ca-cert -v "$CA_CERT"
conjur variable set -i conjur/authn-k8s/ocp/kubernetes/service-account-token -v "$SERVICE_ACCOUNT_TOKEN"
conjur variable set -i conjur/authn-k8s/ocp/kubernetes/api-url -v "$API_URL"

set +x
