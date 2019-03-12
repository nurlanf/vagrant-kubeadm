#!/usr/bin/env bash
swapoff -a
sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab
echo net/bridge/bridge-nf-call-ip6tables = 1 >> /etc/ufw/sysctl.conf
echo net/bridge/bridge-nf-call-iptables = 1 >> /etc/ufw/sysctl.conf
echo net/bridge/bridge-nf-call-arptables = 1 >> /etc/ufw/sysctl.conf
apt-get update
apt-get remove docker docker-engine docker.io containerd runc
apt-get install -y \
apt-transport-https \
ca-certificates \
curl \
gnupg-agent \
software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo apt-key add -
add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/ubuntu \
   $(lsb_release -cs) \
   stable"
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
apt-get install -y kubelet kubeadm kubectl

