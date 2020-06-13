#!/bin/sh
#  curl -L  https://github.com/azorac/sandstorm/raw/master/Setup-KVM.sh | bash
#Install standard utilities
sudo dnf -y install nano net-tools git

#Clone openstack-lab
mkdir sandstorm
git clone git://github.com/azorac/sandstorm sandstorm --branch master

#Install KVM/QEMU
sudo dnf -y install qemu-kvm libvirt libguestfs-tools virt-install

#Install and configure network bridge utilities to enable VM to communicate to the rest of the world
sudo dnf -y install bridge-utils
sudo usermod -aG libvirt $USER #add installing user to the libvirt group

#Configure network
echo BRIDGE=br0 | sudo tee --append /etc/sysconfig/network-scripts/ifcfg-eno1
sudo mv sandstorm/ifcfg-br0 /etc/sysconfig/network-scripts/

##
#Create VM folder
##
sudo mkdir /vm
sudo mkdir /vm/iso
sudo mkdir /vm/disk

##
#set VM folder ACL
##
sudo setfacl -m g:libvirt:rx /vm
sudo setfacl -m g:libvirt:rx /vm/iso
sudo setfacl -m g:libvirt:rwx /vm/disk

#Set autostart and Start libvirtd
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
export LIBVIRT_DEFAULT_URI="qemu:///system"

#Setup SSH keys
echo "Setting up SSH keys..."
ssh-keygen -f id_rsa -t rsa -N ''

#Enable use of SSH keys to new VMs (appending to VM kickstart file)
echo "%post --log=/root/postinstall.log"  >> sandstorm/preseed.cfg
echo "mkdir -m0700 /root/.ssh/" >> sandstorm/preseed.cfg
echo -n 'echo "' >> sandstorm/preseed.cfg
echo -n "$(cat .ssh/id_rsa.pub)" >> sandstorm/preseed.cfg
echo '" > /root/.ssh/authorized_keys' >> sandstorm/preseed.cfg
echo "chmod 0600 /root/.ssh/authorized_keys" >> sandstorm/preseed.cfg
echo "restorecon -R /root/.ssh/"  >> sandstorm/preseed.cfg
echo "%end"  >> sandstorm/preseed.cfg

##
# Download CentOS iso
##
curl http://ftp.ember.se/centos/7.6.1810/isos/x86_64/CentOS-7-x86_64-Minimal-1810.iso > centos.iso
sudo mv centos.iso /vm/iso

sudo reboot
