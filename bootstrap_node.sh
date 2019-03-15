#!/usr/bin/env bash
source config
kubeadm join $MASTER_IPADDR:6443 --token $TOKEN --discovery-token-unsafe-skip-ca-verification
