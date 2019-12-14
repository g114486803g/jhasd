#!/bin/bash
MasterIP1=2.1.1.12
MasterIP2=2.1.1.31
MasterIP3=2.1.1.32
MasterPort=6443

docker run -d --restart=always --name HAProxy-K8S -p 6444:6444 \
        -e MasterIP1=$MasterIP1 \
        -e MasterIP2=$MasterIP2 \
        -e MasterIP3=$MasterIP3 \
        -e MasterPort=$MasterPort \
        -v /data/lb/etc/haproxy.cfg:/usr/local/etc/haproxy/haproxy.cfg \
        wise2c/haproxy-k8s
