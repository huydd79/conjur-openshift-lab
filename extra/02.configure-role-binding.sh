#/bin/sh

set -x
#oc new-project dap1
oc project dap1
oc create serviceaccount conjur-follower -n dap1

openssl s_client -showcerts \
    -connect conjur-master.demo.local:443 \
    -servername conjur-master.demo.local </dev/null | \
    sed -ne '/-BEGIN CERTIFICATE-/,/-END CERTIFICATE-/p' > \
    /tmp/master-certificate.pem

oc create configmap conjur.master-cert \
    --from-file=conjur.master-cert=<(cat /tmp/master-certificate.pem)


oc apply -f conjur-authenticator-role.yaml
oc apply -f conjur-authenticator-clusterole-binding.yaml

set +x
