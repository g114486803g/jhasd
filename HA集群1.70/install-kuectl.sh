#!/bin/bash

#关闭SELinux、防火墙
systemctl stop firewalld
systemctl disable firewalld
setenforce 0
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

#关闭系统的Swap

swapoff -a



# 安装ifconfig
yum install net-tools -y

# 时间同步
yum install -y ntpdate wget 

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

wget https://download.docker.com/linux/centos/docker-ce.repo -P /etc/yum.repos.d/

#安装包
yum install -y kubelet kubeadm kubectl
yum install -y docker-ce docker-ce-cli containerd.io

systemctl enable kubelet docker 
systemctl start docker 

#配置L2网桥在转发包时会被iptables的FORWARD规则所过滤，该配置被CNI插件需要


echo """
vm.swappiness = 0
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
""" > /etc/sysctl.conf
sysctl -p

#同步时间
ntpdate -u ntp1.aliyun.com

#开启IPVS（如果未升级内核，去掉ip_vs_fo）
cat > /etc/sysconfig/modules/ipvs.modules <<EOF
#!/bin/bash
ipvs_modules="ip_vs ip_vs_lc ip_vs_wlc ip_vs_rr ip_vs_wrr   ip_vs_lblc ip_vs_lblcr ip_vs_dh ip_vs_sh ip_vs_fo   ip_vs_nq ip_vs_sed ip_vs_ftp nf_conntrack"
for kernel_module in \${ipvs_modules}; do
    /sbin/modinfo -F filename \${kernel_module} > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        /sbin/modprobe \${kernel_module}
    fi
done
EOF

chmod 755 /etc/sysconfig/modules/ipvs.modules && bash /etc/sysconfig/modules/ipvs.modules && lsmod | grep ip_vs

#所有机器需要设定/etc/sysctl.d/k8s.conf的系统参数
# https://github.com/moby/moby/issues/31208 
# ipvsadm -l --timeout
# 修复ipvs模式下长连接timeout问题 小于900即可
cat <<EOF > /etc/sysctl.d/k8s.conf
net.ipv4.tcp_keepalive_time = 600
net.ipv4.tcp_keepalive_intvl = 30
net.ipv4.tcp_keepalive_probes = 10
net.ipv6.conf.all.disable_ipv6 = 1
net.ipv6.conf.default.disable_ipv6 = 1
net.ipv6.conf.lo.disable_ipv6 = 1
net.ipv4.neigh.default.gc_stale_time = 120
net.ipv4.conf.all.rp_filter = 0
net.ipv4.conf.default.rp_filter = 0
net.ipv4.conf.default.arp_announce = 2
net.ipv4.conf.lo.arp_announce = 2
net.ipv4.conf.all.arp_announce = 2
net.ipv4.ip_forward = 1
net.ipv4.tcp_max_tw_buckets = 5000
net.ipv4.tcp_syncookies = 1
net.ipv4.tcp_max_syn_backlog = 1024
net.ipv4.tcp_synack_retries = 2
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.netfilter.nf_conntrack_max = 2310720
fs.inotify.max_user_watches=89100
fs.may_detach_mounts = 1
fs.file-max = 52706963
fs.nr_open = 52706963
net.bridge.bridge-nf-call-arptables = 1
vm.swappiness = 0
vm.overcommit_memory=1
vm.panic_on_oom=0
EOF

sysctl --system

######重启系统########
#reboot

#####################
cd ~/
# 创建集群信息文件
echo """
CP0_IP=10.2.2.21
CP1_IP=10.2.2.22
CP2_IP=10.2.2.23
VIP=10.2.2.8
NET_IF=eth0
CIDR=10.244.0.0/16
""" > ./cluster-info

###################
echo """
apiVersion: kubeadm.k8s.io/v1beta2
kind: ClusterConfiguration
kubernetesVersion: v1.17.0
controlPlaneEndpoint: "10.2.2.8:6444"
imageRepository: "registry.aliyuncs.com/google_containers"
networking:
  podSubnet: "10.244.0.0/16"
apiServer:
  certSANs:
  - ${CP0_IP}
  - ${CP1_IP}
  - ${CP2_IP}
  - ${VIP}

---
apiVersion: kubeproxy.config.k8s.io/v1alpha1
kind: KubeProxyConfiguration
mode: ipvs
""" > /etc/kubernetes/jb.yaml

kubeadm init --config=jb.yaml --upload-certs | tee bbcc.log
