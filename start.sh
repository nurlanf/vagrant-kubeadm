#!/usr/bin/env bash
source config
sed -i "s/VAGRANT_PROVIDER/$VAGRANT_PROVIDER/g" Vagrantfile
echo "Deploying Vagrant machines"
vagrant up
vagrant status
echo "Updating kubeconfig"
vagrant ssh kube-master -- cat /home/vagrant/.kube/config > $HOME/.kube/config-vagrant

export  KUBECONFIG=$KUBECONFIG:$HOME/.kube/config:$HOME/.kube/config-vagrant
echo "export  KUBECONFIG=$KUBECONFIG:$HOME/.kube/config:$HOME/.kube/config-vagrant" >> $HOME/.bashrc
echo "To use new deployed Kubernetes run"
echo "# source $HOME/.bashrc"
echo "# kubectl config use-context kubernetes-admin@kubernetes"
