# Setting up Conjur Follower with Openshift Operators
This lab guide is working for conjur version 12.4 and openshift crc v4.9.

### Video on step by step setting up this LAB is at https://www.youtube.com/watch?v=-LNENY7F7wA

For more detail on how to enable kubernetes authenticator, please read <https://docs.cyberark.com/product-doc/onlinehelp/aam-dap/latest/en/content/integrations/k8s-ocp/k8s-k8s-authn.htm>

For more detail on how to setup conjur follower, please follow <https://docs.cyberark.com/Product-Doc/OnlineHelp/AAM-DAP/Latest/en/Content/Integrations/k8s-ocp/k8s-follower-conts-dply.htm>

### Lab prerequisites
- Completed all steps in conjur-openshift-lab to setup conjur and crc environments
- Login to crcvm with crcuser and login to crc with kubeadmin user
- Change the 00.config.sh content to match your lab environment, set READY=true when done. Using below configuration as example
```
READY=true
NODE_NAME=conjur1
CONJUR_HOST=conjur-master
LAB_DOMAIN=demo.local
SERVICE_ID=conjur-authenticator
AUTHN_NS=conjur-authn
AUTHN_SA=conjur-authn
AUTHN_ROLE=conjur-authn
FOLLOWER_NS=conjur-follower
FOLLOWER_SA=conjur-follower
FOLLOWER_HOST_ID=conjur-follower
```
- Change working directory to extra/openshif-operators folder

## 1. Init conjur CLI environmnet
```
./00.conjur-cli-login.sh
```
## 2. Enabling conjur authenticator
```
./01.conjur-enable-k8s-authn.sh
./02.k8s-configure-role-binding.sh
./03.conjur-push-k8s-authn-data.sh
```
## 3. Creating conjur follower environment
```
./04.k8s-add-config-map.sh
./05.k8s-add-follower-policy.sh
```
## 4. Installing Follower Operator
- Login to openshift web GUI
- Select follower project
- Go to Operators > OperatorHub and search for CyberArk
- Select Operator and click Install
- Select ```A specific namespace on the cluster``` and click on Install
- Check the result on ```Installed Operators```
## 5. Creating Conjur Follower
- Login to Openshift web GUI and go to followe project with Conjur follower operators installed
- Go to Operators > Installed Operators and click on ```Conjur Enterprise Follower Operator```
- Select ```ConjurFollower``` and click on Create ConjurFollower and put in below configuration data as sample
- Name: conjur-follower-1
- Click on ```Conjur Cluster Configuration```
  - Conjur Account: DEMO
  - Authentication Service ID: conjur-authenticator
  - Application Identity: host/conjur-follower
  - CA Certificate: select ```From a ConfigMap``` and choose ```conjur.master-cert``` as Name and Key
  - Conjur Cluster Master FQDN: conjur-master.demo.local
- Click on Advance configuration
  - On ```Container Environment Variables``` click on Conjur > Add Conjur. Enter Name: CONJUR_AUTHENTICATORS and Value: authn, authn-k8s/conjur-authenticator
  - On ```Kubernetes Resources``` set Service Account as conjur-follower
- Click on ```Create``` to create follower
## 6. Troubleshooting result
- Go to Workloads > Pods
- Click on new Pods which has just created (with name conjur-follower and status Init)
- Click on Logs tab and select configurator from the container dropbox. Watching configurator log for the detail authentication
- Open Conjur master dashboard to see detail authentication result (success/error)
- When follower pods all up and running, go to Networking > Routes and create a new route for follower
  - Name: follower-1
  - Service: conjur-follower
  - Target port: 443 -> 9443 (TCP)
  - Check on Secure Route
  - TLS termination: Pasthrough
  - Insecure traffic: Redirect
  - Click on ```Create``` when done
- Using browser, go to https://follower-1-conjur-follower.apps-crc.testing/info to get detail information of new follower. Make sure k8s authenticator is configured and enabled

# LAB END
