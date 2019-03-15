ENV['VAGRANT_DEFAULT_PROVIDER'] = "libvirt"
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

  config.vm.define "kube-master" do |master|
    master.vm.hostname = "kube-master"
    master.vm.box = "generic/ubuntu1810"
    master.vm.network "private_network", ip: "192.168.50.4"
    master.vm.provision :shell, :privileged => true, :path => "bootstrap_master.sh"
    #master.vm.synced_folder '.', '/vagrant', :disabled => true
  end

  config.vm.define kube-node1 do |node|
    node.vm.hostname = kube-node1
    node.vm.network private_network, ip: "192.168.50.5"
    node.vm.provision :shell, :privileged => true, :path => bootstrap_node.sh
    node.vm.box = generic/ubuntu1810
    #node.vm.synced_folder '.', '/vagrant', :disabled => true
  end


  config.vm.define kube-node2 do |node|
    node.vm.hostname = kube-node2
    node.vm.network private_network, ip: "192.168.50.6"
    node.vm.provision :shell, :privileged => true, :path => bootstrap_node.sh
    node.vm.box = generic/ubuntu1810
    #node.vm.synced_folder '.', '/vagrant', :disabled => true
  end

end
