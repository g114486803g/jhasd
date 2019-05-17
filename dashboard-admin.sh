#!/bin/bash

cd /etc/kubernetes/pki/ 

(umask 077; openssl  genrsa -out dashboard.key 2048)

openssl req -new -key dashboard.key -out dashboard.csr -subj "/O=jbjb/CN=dashboard"

openssl x509 -req -in dashboard.csr -CA ca.crt -CAkey ca.key -CAcreateserial -out dashboard.crt -days 366 


kubectl create secret generic dashboard-cert -n  kube-system --from-file=dashboard.crt=./dashboard.crt --from-file=dashboard.key=./dashboard.key


kubectl get secrets -n kube-system  | grep kubernetes

kubectl create serviceaccount dashboard-admin -n kube-system

kubectl create clusterrolebinding dashboard-cluster-admin --clusterrole=cluster-admin --serviceaccount=kube-system:dashboard-admin

echo "或者命牌"
kubectl get secrets -n kube-system  | grep dashboard-admin 

kubectl describe secrets dashboard-admin-token-97kg8 -n kube-system

cd ~

exit
