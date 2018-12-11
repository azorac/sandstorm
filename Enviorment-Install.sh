#!/bin/sh
# Run: sudo yum -y install git
#
#Install aditional applications
yum -y install nano

#Clone openstack-lab
git clone git://git.openstack.org/openstack/training-labs --branch master

#Rename clone folder
mv training-labs OpenStack-lab

#Set up variables
cat <<'EOM' >> ~/.bashrc

OS_LAB=/home/azorac/OpenStack-lab
OS_ST=/home/azorac/OpenStack-lab/labs
OS_BASH=/home/azorac/OpenStack-lab/labs/osbash
EOM
##
#Modify files
##
#Controller
ex -s -c '%s/VM_MEM=5120/VM_MEM=6144/g|x' $OS_ST/config/config.controller
ex -s -c '%s/# VM_CPUS=1/VM_CPUS=2/g|x' $OS_ST/config/config.controller

#Compute1
ex -s -c '%s/VM_MEM=1024/VM_MEM=8192/g|x' $OS_ST/config/config.compute1
ex -s -c '%s/SECOND_DISK_SIZE=1280/SECOND_DISK_SIZE=25600/g|x' $OS_ST/config/config.compute1
