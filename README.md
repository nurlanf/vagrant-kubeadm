
# Deploying multi-node Kubernetes Cluster via Vagrant and Kubeadm

This repo could help you quickly deploy kubeadm kubernetes cluster in your virtualbox or KVM(libvirt) Virtualization

### Prerequisites
Below binary files should be installed before starting
```
1. Vagrant needs to be installed
2. Virtualbox or KVM(Libvirt) virtualization is installed
3. Kubectl needs to be installed (optional if you want to control your cluster from host machine)
```
### Installing
```
For Installation of Vagrant visit https://www.vagrantup.com/docs/installation/
For Kubectl binary you can visit https://kubernetes.io/docs/tasks/tools/install-kubectl/
```

## Getting Started
1. Edit `config` file, set variables
2. Run `./start.sh` to start provisioning vagrant machines

## `Config` file variables
`VAGRANT_PROVIDER=` libvirt or virtualbox can be defined

`NODE_SIZE=` number of worker nodes

`MASTER_IPADDR=` Ip address of Master node, worker node ip addresses also will be generated in same subnet

`POD_CIDR=` Pod network of cluster

`TOKEN=` You can leave default or change it, this will be used for automatically join

`TOKEN-TTL=` The duration before the token is automatically deleted (e.g. 1s, 2m, 3h). If set to '0', the token will never expire (default is 1h)

## To connect new cluster from host machine (If kubectl is installed on host machine)
After running `./start.sh` script to connect to your cluster run below commands in order update your Kubeconfig with new one.
```
source $HOME/.bashrc
kubectl config use-context kubernetes-admin@kubernetes
```

## To Cleanup
`./destroy.sh`


## Authors

* **Nurlan Farajov** - *Kubernetes Project* - (https://github.com/nurlanf)
