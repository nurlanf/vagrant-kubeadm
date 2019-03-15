#!/usr/bin/env bash
kubeadm join MASTER_IPADDR:6443 --token TOKEN --discovery-token-unsafe-skip-ca-verification
