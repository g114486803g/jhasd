#!/bin/bash

MY_REGISTRY=registry.cn-shenzhen.aliyuncs.com/jbjb/k8s-images
COMMT="docker tag"
COMMP="docker pull"

echo "拉取镜像稍等..."
${COMMP} $MY_REGISTRY:pause
${COMMP} $MY_REGISTRY:etcd
${COMMP} $MY_REGISTRY:coredns
${COMMP} $MY_REGISTRY:kube-scheduler
${COMMP} $MY_REGISTRY:kube-controller-manager
${COMMP} $MY_REGISTRY:kube-apiserver
${COMMP} $MY_REGISTRY:kube-proxy

echo "打tag稍等"
sleep 1
${COMMT} $MY_REGISTRY:pause  k8s.gcr.io/pause:3.1
${COMMT} $MY_REGISTRY:etcd  k8s.gcr.io/etcd:3.3.10
${COMMT} $MY_REGISTRY:coredns  k8s.gcr.io/coredns:1.3.1 
${COMMT} $MY_REGISTRY:kube-scheduler k8s.gcr.io/kube-scheduler:v1.14.1
${COMMT} $MY_REGISTRY:kube-controller-manager k8s.gcr.io/kube-controller-manager:v1.14.1
${COMMT} $MY_REGISTRY:kube-apiserver k8s.gcr.io/kube-apiserver:v1.14.1
${COMMT} $MY_REGISTRY:kube-proxy k8s.gcr.io/kube-proxy:v1.14.1