#!/bin/bash

docker pull registry.cn-shenzhen.aliyuncs.com/jbjb/k8s-jbs:nginx-ingress-controlle

docker tag registry.cn-shenzhen.aliyuncs.com/jbjb/k8s-jbs:nginx-ingress-controller quay.io/kubernetes-ingress-controller/nginx-ingress-controller:0.25.0 

docker rmi registry.cn-shenzhen.aliyuncs.com/jbjb/k8s-jbs:nginx-ingress-controlle
