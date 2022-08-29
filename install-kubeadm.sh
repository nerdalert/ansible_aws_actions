#!/bin/bash
# This is not used by the playbooks, it is only here for reference

# Host dependencies
sudo apt update
sudo apt install -y apt-transport-https ca-certificates curl gnupg2 software-properties-common
sudo sysctl -w net.ipv4.ip_forward=1
sudo modprobe br_netfilter

# Configure kube repos
sudo curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

# Install kube binaries
sudo apt-get update
sudo apt install -y kubeadm=1.24.4-00 kubelet=1.24.4-00 kubectl=1.24.4-00

### Configure cri-o repos
OS=xUbuntu_20.04
CRIO_VERSION=1.23
echo "deb https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable.list
echo "deb http://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable:/cri-o:/$CRIO_VERSION/$OS/ /"|sudo tee /etc/apt/sources.list.d/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION.list
curl -L https://download.opensuse.org/repositories/devel:kubic:libcontainers:stable:cri-o:$CRIO_VERSION/$OS/Release.key | sudo apt-key add -
curl -L https://download.opensuse.org/repositories/devel:/kubic:/libcontainers:/stable/$OS/Release.key | sudo apt-key add -

# Install crio
sudo apt-get update
sudo apt-get -y install cri-o cri-o-runc
sudo systemctl enable crio.service
sudo systemctl start crio.service

# Kubeadm
sudo kubeadm init --upload-certs --pod-network-cidr=10.200.0.0/16 --v=6 --skip-phases=addon/kube-proxy

# Kubeconfig
mkdir -p /home/ubuntu/.kube
sudo cp -i /etc/kubernetes/admin.conf /home/ubuntu/.kube/config
sudo chown $(id -u ubuntu):$(id -g ubuntu) /home/ubuntu/.kube/config
export KUBECONFIG=/home/ubuntu/.kube/config
