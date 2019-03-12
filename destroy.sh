#!/usr/bin/env bash
echo "Removing config file"
unset KUBECONFIG
rm -f $HOME/.kube/config-vagrant
sed -i '/KUBECONFIG/d' $HOME/.bashrc
echo "Destroying Vagrant machines"
vagrant destroy -f
vagrant status