#!/usr/bin/env bash
NODENAME=$(hostname -s)
kubeadm join 192.168.50.4:6443 --token qnq2lo.v0acaocjegmzf06c --discovery-token-unsafe-skip-ca-verification --node-name kube-master
