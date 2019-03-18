#!/usr/bin/env bash
source config
echo "Checking if Vagrant is installed"
echo ""
sleep 1
if ! command -v vagrant;
 then
    echo "Please install Vagrant"
    echo "For more installation https://www.vagrantup.com/docs/installation/"
    exit 1
 else
    echo "Vagrant is installed"
fi

echo "Checking if Kubectl is installed"
echo ""
sleep 1
if ! command -v kubectl;
then
while true; do
  echo "Kubectl is not installed. You won't able to control your Kubernetes cluster from this machine without kubectl"
  read -p "Do you want to continue?(Not recommended): [y or n]" yn
  case $yn in
      [Yy]* ) echo "Continuing without kubectl"; continue ;;
      [Nn]* ) echo "Please install kubectl"; exit 1 ;;
      * ) echo "Please install kubectl"; echo "for installation visit https://kubernetes.io/docs/tasks/tools/install-kubectl/"; exit 1 ;;
  esac
done
else
echo "Kubectl is installed, continuing ..."
sleep 1
fi

if [ -f bootstrap_master.sh ]; then
echo "backing up bootstrap_master.sh"
mv -v bootstrap_master.sh bootstrap_master.sh_$(date '+%d-%m-%y_%H-%M')
fi

echo "Creating new bootstrap_master.sh"

cat << EOF > bootstrap_master.sh
#!/usr/bin/env bash
# DON'T CONFIGURE THIS FILE
kubeadm init --apiserver-advertise-address=$MASTER_IPADDR --pod-network-cidr=$POD_CIDR --token $TOKEN --token-ttl $TOKENTTL
sudo --user=vagrant mkdir -p /home/vagrant/.kube
cp -i /etc/kubernetes/admin.conf /home/vagrant/.kube/config
chown \$(id -u vagrant):\$(id -g vagrant) /home/vagrant/.kube/config
mkdir -p \$HOME/.kube
cp -i /etc/kubernetes/admin.conf \$HOME/.kube/config
kubectl apply -f https://docs.projectcalico.org/v3.2/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
kubectl apply -f https://docs.projectcalico.org/v3.2/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml
EOF
sleep 1


if [ -f bootstrap_node.sh ]; then
echo "backing up bootstrap_master.sh"
mv -v bootstrap_node.sh bootstrap_node.sh_$(date '+%d-%m-%y_%H-%M')
fi

echo "Creating new bootstrap_node.sh"
cat << EOF > bootstrap_node.sh
#!/usr/bin/env bash
# DON'T CONFIGURE THIS FILE
kubeadm join $MASTER_IPADDR:6443 --token $TOKEN --discovery-token-unsafe-skip-ca-verification
EOF
sleep 1

if [ -f Vagrantfile ]; then
echo "backing up Vagrantfile"
mv -v Vagrantfile Vagrantfile_$(date '+%d-%m-%y_%H-%M')
fi
echo "Creating new Vagrantfile"
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
sleep 1

echo "Deploying Vagrant machines"
sleep 1
vagrant up

echo "Copying kubeconfig file from master node to host"
vagrant ssh kube-master -- cat /home/vagrant/.kube/config > $HOME/.kube/config-vagrant &&

if ! grep -q 'export  KUBECONFIG=$KUBECONFIG:$HOME/.kube/config:$HOME/.kube/config-vagrant' $HOME/.bashrc;
then
echo "export  KUBECONFIG=$KUBECONFIG:$HOME/.kube/config:$HOME/.kube/config-vagrant" >> $HOME/.bashrc
fi
echo "RUN below commands to use new deployed kubernetes"
echo ""
echo "source $HOME/.bashrc"
echo "kubectl config use-context kubernetes-admin@kubernetes"
