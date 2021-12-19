#!/bin/sh

#Change your configuration and set READY=true when done
READY=false

#Conjur master container name
NODE_NAME=conjur1

#Conjur master host name
CONJUR_HOST=conjur-master

#Lab domain name
LAB_DOMAIN=demo.local

#K8s authn service ID
SERVICE_ID=conjur-openshift-follower

#Authenticator namespace
AUTHN_NS=cyberark-conjur

#Authn service account
AUTHN_SA=conjur-follower

#Authn role name
AUTHN_ROLE=conjur-authenticator

#Follower namespace
FOLLOWER_NS=$AUTHN_NS

#Follower service account
FOLLOWER_SA=$AUTHN_SA

#Follower host ID
FOLLOWER_HOST_ID=$SERVICE_ID


