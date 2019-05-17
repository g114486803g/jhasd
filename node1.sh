#!/bin/bash

#yum源配置

systemctl stop firewalld.service 
systemctl disable firewalld.service
cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://mirrors.aliyun.com/kubernetes/yum/repos/kubernetes-el7-x86_64/
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://mirrors.aliyun.com/kubernetes/yum/doc/yum-key.gpg
       https://mirrors.aliyun.com/kubernetes/yum/doc/rpm-package-key.gpg
EOF

wget https://download.docker.com/linux/centos/docker-ce.repo -P /tmp

# 关闭selinux
setenforce 0
sed -i 's/^SELINUX=enforcing$/SELINUX=disabled/' /etc/selinux/config

#关闭Swap
swapoff -a

#路由设置看需要可以不设置
cat <<EOF >  /etc/sysctl.d/k8s.conf
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
vm.swappiness=0
EOF
sysctl --system
sysctl -p /etc/sysctl.d/k8s.conf

clear 
echo "-----------我的淫荡的分割线-------------------------"
echo "开始安装二进制包请稍后"
yum makecache fast

yum install -y kubelet kubeadm kubectl
yum install -y docker-ce docker-ce-cli containerd.io

systemctl enable kubelet docker 
systemctl start docker 

echo "-----------配置docker阿里云加速器------------"

tee /etc/docker/daemon.json <<-'EOF'
{
  "registry-mirrors": ["https://0k0953tv.mirror.aliyuncs.com"]
}
EOF

systemctl daemon-reload
systemctl restart docker
echo "稍等2秒准备开始初始化集群"
sleep 2

echo "安装flannel网卡"
kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml

echo "安装完成请加入master集群。。。。。"

