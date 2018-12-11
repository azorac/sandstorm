#!/bin/sh
# Run: sudo yum -y install git
#  curl -L  https://github.com/azorac/sandstorm/raw/master/Enviorment-Install.sh | bash
#Install aditional applications
#sudo yum -y install nano

#Clone openstack-lab
git clone git://git.openstack.org/openstack/training-labs --branch master

#Rename clone folder
mv training-labs OpenStack-lab

#Set up variables
sudo cat <<'EOM' >> ~/.bashrc

OS_LAB=/home/azorac/OpenStack-lab
OS_ST=/home/azorac/OpenStack-lab/labs
OS_BASH=/home/azorac/OpenStack-lab/labs/osbash
EOM
##
#Modify files
##
#Configure Controller
ex -s -c '%s/VM_MEM=5120/VM_MEM=6144/g|x' /home/azorac/OpenStack-lab/labs/config/config.controller
ex -s -c '%s/# VM_CPUS=1/VM_CPUS=2/g|x' /home/azorac/OpenStack-lab/labs/config/config.controller

#Configure Compute1
ex -s -c '%s/VM_MEM=1024/VM_MEM=8192/g|x' /home/azorac/OpenStack-lab/labs/config/config.compute1
ex -s -c '%s/SECOND_DISK_SIZE=1280/SECOND_DISK_SIZE=25600/g|x' /home/azorac/OpenStack-lab/labs/config/config.compute1

#Add to compute and Control to Host file
cat << EOF | sudo tee --append /etc/hosts
# ------------------
# Virtualised nodes
# ------------------
# controller
10.0.0.11 controller
# compute1
10.0.0.31 compute1
EOF

###########################
## 4. Setup OpenStack training labs on KVM/QEMU
###########################

#Install KVM/QEMU
sudo yum -y install qemu-kvm libvirt libvirt-python libguestfs-tools virt-install

#Install and configure network bridge utilities to enable VM to communicate to the rest of the world
sudo yum -y install bridge-utils
sudo usermod -aG libvirt `id -un`

#Set autostart and Start libvirtd
sudo systemctl enable libvirtd
sudo systemctl start libvirtd
##
## To connect to "virsh connect qemu:///system"
##

############################
## Create and configure Open-Stack VMS
############################
cd $OS_ST
./st.py --build cluster --provider kvm 
