####
# Variables
####
DEBUG_LEVEL=0
VM_NAME=""
VM_MAC_Addr=""
VM_IP_Addr=""
VM_State=""

###
# Command line args
###
while [ "$1" != "" ]; do
    case $1 in
        -n | --name )           shift
                                VM_NAME=$1
                                ;;
        -d | --debuglevel )     shift
								DEBUG_LEVEL=$1
                                ;;
        * )                     usage
                                exit 1
    esac
    shift
done

####
# Functions
####
logOut () {
	if [ $DEBUG_LEVEL == 1 ]; then
		if [ "$1" == "." ]; then
			echo -n "$1"
		else
			echo "$1"
		fi
	fi
}

##
# Start install
##
virt-install -n $VM_NAME -r 2048 --vcpus=2 --accelerate --nographics -v -l /vm/iso/centos.iso --network=bridge=br0,model=virtio --disk path=/vm/disk/$VM_NAME.img,size=20 --initrd-inject preseed.cfg --extra-args="ks=file:/preseed.cfg console=tty0 console=ttyS0,115200" --noautoconsole > logOut

####
# Get MAC
####
logOut "Wating for install to start!"
sleep 10
while true; do
	#Get MAC address from VM
	VM_MAC_Addr=$(virsh domiflist $VM_NAME | grep -o -E "([0-9a-f]{2}:){5}([0-9a-f]{2})")
	if [ "$VM_MAC_Addr" != "" ]; then
		logOut "Mac found ($VM_MAC_Addr)"
		break
	fi
	logOut "."
	sleep 1
done

#####
## GET IP
#####
## Send UDP package to all IPs in scope, for arp discovery
sleep 1

#Use ARP to get IP from MAC
while true; do
	#Get IP address from VM
	max=254
	for i in `seq 100 $max`
	do
		echo "T" > /dev/udp/192.168.1.$i/3000
	done

	VM_IP_Addr=$(arp -e | grep $VM_MAC_Addr | grep -o -P "^\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}")
	if [ "$VM_IP_Addr" != "" ]; then
		logOut "IP found ($VM_IP_Addr)"
		break
	fi
	max=10
	for i in `seq 0 $max`
	do
		logOut "."
		sleep 1
	done
done

###
# Wating for OS install to finish
###
logOut "Wating for install for OS install to finish."
while true; do
	#Get MAC address from VM
	VM_State=$(virsh list --state-shutoff | grep -o $VM_NAME)
	if [ "$VM_State" != "" ]; then
		logOut "Install finish!"
		break
	fi
	logOut "."
	sleep 1
done

logOut "Starting VM!"
virsh start $VM_NAME > logOut

logOut "To connect to the VM use:"
logOut "--------------------------"
logOut "ssh root@$VM_IP_Addr"
