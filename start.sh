#!/usr/bin/env bash
source config
cat << EOF > bootstrap_master.sh
#!/usr/bin/env bash
# DON'T CONFIGURE THIS FILE
kubeadm init --apiserver-advertise-address=$MASTER_IPADDR --pod-network-cidr=$POD_CIDR --token $TOKEN
sudo --user=vagrant mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown \$(id -u vagrant):\$(id -g vagrant) /home/vagrant/.kube/config
mkdir -p \$HOME/.kube
cp -i /etc/kubernetes/admin.conf \$HOME/.kube/config
kubectl apply -f https://docs.projectcalico.org/v3.2/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
kubectl apply -f https://docs.projectcalico.org/v3.2/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
EOF
cat << EOF > bootstrap_node.sh
#!/usr/bin/env bash
# DON'T CONFIGURE THIS FILE
kubeadm join $MASTER_IPADDR:6443 --token $TOKEN --discovery-token-unsafe-skip-ca-verification
EOF
cat << EOF > Vagrantfile
# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = "$VAGRANT_PROVIDER"
EOF
if [[ $VAGRANT_PROVIDER == libvirt ]];
then
cat << EOF >> Vagrantfile
# Check required plugins
REQUIRED_PLUGINS_LIBVIRT = %w(vagrant-libvirt)
exit unless REQUIRED_PLUGINS_LIBVIRT.all? do |plugin|
  Vagrant.has_plugin?(plugin) || (
    puts "The #{plugin} plugin is required. Please install it with:"
    puts "$ vagrant plugin install #{plugin}"
    false
  )
end
EOF
fi
cat << EOF >> Vagrantfile
Vagrant.configure("2") do |config|

  # Ubuntu VM
  config.vm.box = "generic/ubuntu1810"
  config.vm.provision :shell, :privileged => true, :path => "bootstrap_all.sh"

  config.vm.define "kube-master" do |master|
    master.vm.hostname = "kube-master"
    master.vm.box = "generic/ubuntu1810"
    master.vm.network "private_network", ip: "$MASTER_IPADDR"
    master.vm.provision :shell, :privileged => true, :path => "bootstrap_master.sh"
    #master.vm.synced_folder '.', '/vagrant', :disabled => true
  end
EOF
./add_node_to_vagrantfile.sh >> Vagrantfile

echo "end" >> Vagrantfile;

echo "Deploying Vagrant machines"
vagrant up
echo "Updating kubeconfig"
vagrant ssh kube-master -- cat /home/vagrant/.kube/config > $HOME/.kube/config-vagrant &&

export  KUBECONFIG=$KUBECONFIG:$HOME/.kube/config:$HOME/.kube/config-vagrant
if ! grep -q 'export  KUBECONFIG=$KUBECONFIG:$HOME/.kube/config:$HOME/.kube/config-vagrant' $HOME/.bashrc;
then
echo "export  KUBECONFIG=$KUBECONFIG:$HOME/.kube/config:$HOME/.kube/config-vagrant" >> $HOME/.bashrc
fi
echo "To use new deployed Kubernetes run"
echo "# source $HOME/.bashrc"
echo "# kubectl config use-context kubernetes-admin@kubernetes"
