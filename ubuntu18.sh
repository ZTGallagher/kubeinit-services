#/bin/bash

## Make sure yum-config-manager is installed

yum -y install yum-utils

## Add Docker GPG key and repository

rpm --import https://download.docker.com/linux/centos/gpg
yum-config-manager --add-repo https://download.docker.com/linux/centos/docker-ce.repo


## Upgrade and install necessary docker dependencies.
## Then enable and start docker

yum upgrade -y
yum install -y docker-ce yum-utils device-mapper-persistent-data lvm2 containerd.io docker-ce-cli
systemctl enable docker --now


## No easy *.repo file, so create one manually for Kubernetes

bash -c 'cat <<EOF > /etc/yum.repos.d/kubernetes.repo
[kubernetes]
name=Kubernetes
baseurl=https://packages.cloud.google.com/yum/repos/kubernetes-el7-x86_64
enabled=1
gpgcheck=1
repo_gpgcheck=1
gpgkey=https://packages.cloud.google.com/yum/doc/yum-key.gpg https://packages.cloud.google.com/yum/doc/rpm-package-key.gpg
EOF'


## Install necessary components

yum install -y kubelet kubeadm kubectl


## Disable swap or kubelet won't start
## Kubernetes requires swap disabled to run at all, to guarantee pods never use swap space
## https://github.com/kubernetes/kubernetes/issues/53533

swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab


## Kubernetes requires iptables for filtering and port forwarding
## So setting the bridge is required

echo "net.bridge.bridge-nf-call-iptables=1" | tee -a /etc/sysctl.conf
sysctl -p


## Start kubelet. This should "just work".

systemctl enable kubelet --now
