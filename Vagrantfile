# -*- mode: ruby -*-
# vi: set ft=ruby :

ENV['VAGRANT_DEFAULT_PROVIDER'] = 'libvirt'

# Check required plugins
REQUIRED_PLUGINS_LIBVIRT = %w(vagrant-libvirt)
exit unless REQUIRED_PLUGINS_LIBVIRT.all? do |plugin|
  Vagrant.has_plugin?(plugin) || (
    puts "The #{plugin} plugin is required. Please install it with:"
    puts "$ vagrant plugin install #{plugin}"
    false
  )
end

Vagrant.configure("2") do |config|

  # Ubuntu VM
  config.vm.box = "generic/ubuntu1810"
  config.vm.provision :shell, :privileged => true, :path => "bootstrap_all.sh"
  config.vm.network "private_network", type: "dhcp"

  config.vm.define "kube-master" do |node|
    node.vm.hostname = "kube-master"
    node.vm.box = "generic/ubuntu1810"
    #node.vm.synced_folder '.', '/vagrant', :disabled => true
  end
  config.vm.define "kube-node1" do |node|
    node.vm.hostname = "kube-node1"
    node.vm.box = "generic/ubuntu1810"
    #node.vm.synced_folder '.', '/vagrant', :disabled => true
  end
end
