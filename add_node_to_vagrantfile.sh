#!/usr/bin/env bash
source config

MaxValue=255    # highest valid IP octet value

baseaddr="$(echo $MASTER_IPADDR | cut -d. -f1-3)"
lsv="$(echo $MASTER_IPADDR | cut -d. -f4)"
count=$NODE_SIZE
NUM=1
while [ $count -gt 0 ]
do
   if [ $lsv -eq $MaxValue ] ; then
    # here you'll need to increment the third level IP value,
    # but that might cascade into the second, or the first.
    # consider the case of 17.255.255.255 + 1
    echo "edge case needs to be written"
  fi
  lsv=$(( $lsv + 1 ))
  NODE_IPADDR=$baseaddr.$lsv
echo "
  config.vm.define \"kube-node$NUM\" do |node|
    node.vm.hostname = \"kube-node$NUM\"
    node.vm.network \"private_network\", ip: \"$NODE_IPADDR\"
    node.vm.provision :shell, :privileged => true, :path => \"bootstrap_node.sh\"
    node.vm.box = \"generic/ubuntu1810\"
    #node.vm.synced_folder '.', '/vagrant', :disabled => true
  end
"
  count=$(( $count - 1 ))
  NUM=$(($NUM + 1))
done

exit 0
