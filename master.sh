------- 手动输入这里然后删除---------------------
cat <<EOF > /etc/sysconfig/modules/ipvs.modules
#!/bin/sh
ipvs_mods_dir="/usr/lib/modules/$(uname -r)/kernel/net/netfilter/ipvs/"
for mod in `ls ${ipvs_mods_dir} | grep -o "^[^.]*"`; do
    /sbin/modprobe $mod
done

EOF

-------------------------

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

yum install ipset ipvsadm wget bash-completion.noarch -y
wget https://download.docker.com/linux/centos/docker-ce.repo -P /etc/yum.repos.d/

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

chmod +x /etc/sysconfig/modules/ipvs.modules && /etc/sysconfig/modules/ipvs.modules

lsmod | grep -e ip_vs -e nf_conntrack_ipv4
cut -f1 -d " "  /proc/modules | grep -e ip_vs -e nf_conntrack_ipv4
lsmod | grep ip_vs

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

kubeadm init --image-repository registry.aliyuncs.com/google_containers  --pod-network-cidr=10.244.0.0/16

echo "如果得到了令牌请记住"

echo "下载flannel网卡"
wget  https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yml
ls flannel
