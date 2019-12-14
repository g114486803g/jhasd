#!/bin/bash


setenforce 0
sed -i "s/SELINUX=enforcing/SELINUX=disabled/g" /etc/selinux/config

rpm -Uvh http://mirror.rc.usf.edu/compute_lock/elrepo/kernel/el7/x86_64/RPMS/elrepo-release-7.0-4.el7.elrepo.noarch.rpm 
yum clean all

## 安装最新的主线稳定内核
yum --enablerepo=elrepo-kernel install kernel-ml-devel -y
yum --enablerepo=elrepo-kernel install kernel-ml -y

sed -i 's/saved/0/' /etc/default/grub

grub2-mkconfig -o /boot/grub2/grub.cfg

uname -sr
reboot
