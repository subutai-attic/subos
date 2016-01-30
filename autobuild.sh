#!/bin/bash

set -e

# Script usage
function build_usage {
	echo -e "\nBuild, install and export Subutai Snappy"
	echo -e "\nusage:"
	echo "$0 [ -t|--type TYPE ] -e|--export OUTPUT or v|--vm [ -p|--preserve ] or -b|--build"
	echo "Arguments:"
	echo "	-t|--type TYPE		- type: \"rh\", \"mng\" or \"both\". Not required argument, assuming both by default"
	echo "	-e|--export OUTPUT	- type of output file: \"ova\", \"box\" or \"both\". Assuming both by default. This option will rebuild temporary snap"
	echo "	-b|--build		- just build snap package"
	echo "	-v|--vm			- create and run preconfigured virtual machine. Th
is command will rebuild temporary snap package and install it inside the VM"
	echo "	-p|--preserve		- if exist, re-use temporary snap"
	echo "	-h|--help		- show this text"
	echo -e "\n"

	exit 0
}


function snap_build {
	rm -rf /tmp/tmpdir_$SUB_TYPE
	mkdir -p /tmp/tmpdir_$SUB_TYPE
	for i in $LIST; do
		cp -r $i/* /tmp/tmpdir_$SUB_TYPE
	done
	if [ "$BUILD" == "true" ]; then
		echo "Building $SUB_TYPE snap"
		snappy build /tmp/tmpdir_$SUB_TYPE --output=$EXPORT_DIR/snap
	elif [ "$PRESERVE" == "false" ]; then
		if [ "$SUB_TYPE" == "subutai-mng" ]; then sed -i "/tmp/tmpdir_$SUB_TYPE/bin/start" -e 's/Line to add commands by autobuild (do not change it)/Line to add commands by autobuild (do not change it)\nexit 0 #Delete me after export/g'; fi
		echo "Building $SUB_TYPE temporary snap"
		snappy build "/tmp/tmpdir_$SUB_TYPE" --output=/tmp
	elif [ -f "/tmp/${SUB_TYPE}_4.0.0_amd64.snap" ]; then
		echo "Flag -p is set, using temporary snap"
	else
		if [ "$SUB_TYPE" == "subutai-mng" ]; then sed -i "/tmp/tmpdir_$SUB_TYPE/bin/start" -e 's/Line to add commands by autobuild (do not change it)/Line to add commands by autobuild (do not change it)\nexit 0 #Delete me after export/g'; fi
                echo "$SUB_TYPE temporary snap not found, rebuilding"
                snappy build "/tmp/tmpdir_$SUB_TYPE" --output=/tmp
	fi
	rm -rf /tmp/tmpdir_$SUB_TYPE
}


function clone_vm {
	echo "Creating clone"
	vboxmanage clonevm --register --name $CLONE snappy 
	vboxmanage modifyvm $CLONE --nic1 none
	vboxmanage modifyvm $CLONE --nic2 none
	vboxmanage modifyvm $CLONE --nic4 nat
	vboxmanage modifyvm $CLONE --cableconnected4 on
	vboxmanage modifyvm $CLONE --natpf4 "ssh-fwd,tcp,,4567,,22"
	vboxmanage modifyvm $CLONE --rtcuseutc on
	vboxmanage startvm --type headless $CLONE
	
	echo "Cleaning keys"
	ssh-keygen -f ~/.ssh/known_hosts -R [localhost]:4567

	echo "Waiting for ssh"
	while [ "$(sshpass -p "ubuntu" ssh -o ConnectTimeout=1 -o StrictHostKeyChecking=no ubuntu@localhost -p4567 "ls" > /dev/null 2>&1; echo $?)" != "0" ]; do
		sleep 2
	done
}

function install_snap {
	if [ -f "$HOME/.ssh/id_rsa.pub" ]; then
		echo "Adding user public key"
		pubkey="$(cat $HOME/.ssh/id_rsa.pub)"
		sshpass -p "ubuntu" ssh -o StrictHostKeyChecking=no ubuntu@localhost -p4567 "sudo bash -c 'echo $pubkey >> /root/.ssh/authorized_keys'"
	fi
	echo "Creating tmpfs"
	sshpass -p "ubuntu" ssh -o StrictHostKeyChecking=no ubuntu@localhost -p4567 "mkdir tmpfs; sudo mount -t tmpfs -o size=1G tmpfs /home/ubuntu/tmpfs"
	echo "Copying snap"
	sshpass -p "ubuntu" scp -P4567 prepare-server.sh /tmp/${SUB_TYPE}_4.0.0_amd64.snap ubuntu@localhost:/home/ubuntu/tmpfs/
	echo "Running install script"
	sshpass -p "ubuntu" ssh -o StrictHostKeyChecking=no ubuntu@localhost -p4567 "sudo /home/ubuntu/tmpfs/prepare-server.sh"
}

function prepare_nic {
	echo "Shutting down vm"
	vboxmanage controlvm $CLONE poweroff
	echo "Restoring network"
	sleep 5
	vboxmanage modifyvm $CLONE --nic4 none
        vboxmanage modifyvm $CLONE --nic2 bridged
        vboxmanage modifyvm $CLONE --nic1 intnet
}

function export_ova {
	echo "Exporting OVA image"
	mkdir -p "$EXPORT_DIR/ova"
	vboxmanage export $CLONE -o $EXPORT_DIR/ova/${CLONE}.ova --ovf20
}

function export_box {
	mkdir -p "$EXPORT_DIR/vagrant/$SUB_TYPE"
	local dst="$EXPORT_DIR/vagrant/$SUB_TYPE"

	echo "Exporting Vagrant box"
	vagrant init $CLONE ${CLONE}.box	
	vagrant package --base $CLONE --output $dst/${CLONE}.box
	
	mv -f Vagrantfile .vagrant $dst

	sed -i $dst/Vagrantfile -e 's/config\.ssh\.forward_agent = true/config\.ssh\.forward_agent = true\n  config\.ssh\.username = \"ubuntu\"\n  config\.vm\.synced_folder \"\.\", \"\/vagrant\", disabled: true\n  config\.vm\.network \"forwarded_port\", guest: 8181, host: 8181/g'

        if [ "$SUB_TYPE" == "subutai-mng" ]; then
                sed -i $dst/Vagrantfile -e 's/config\.vm\.synced_folder \"\.\", \"\/vagrant\", disabled: true/config\.vm\.synced_folder \"\.\", \"\/vagrant\", disabled: true\n  config\.vm\.network \"forwarded_port\", guest: 8181, host: 8181/g'
        fi
}

function setup_mng_var {
	SUB_TYPE="subutai-mng"
       	LIST="btrfs collectd common curl lxc-mng cgmanager-mng dnsmasq influxdb java lighttpd ovs rngd mh p2p subutai-mng subutai awsdeploy"
       	CLONE=mng-autobuild-"$DATE"
}

function setup_rh_var {
	SUB_TYPE="subutai"
        LIST="btrfs collectd common curl lxc ovs rh rngd subutai cgmanager p2p"
       	CLONE=rh-autobuild-"$DATE"
}

EXPORT="false"
BUILD="false"
TYPE="rh"
PRESERVE="false"
VM="false"
EXPORT_DIR="../export"
DATE="$(date +%s)"

if [ "$#" == "0" ]; then BUILD="true"; fi

while [ $# -ge 1 ]; do
	key="$1"

	case $key in
	    -t|--type)
		    TYPE="$2"
		    if [[ $2 =~ -. ]]; then 
		    	TYPE="both"; 
		    fi	    
		    if [[ "$2" == "" ]]; then 
		    	TYPE="both"; 
		    fi
	    ;;
	    -e|--export)
		    EXPORT="$2"
		    if [[ $2 =~ -. ]]; then 
		    	EXPORT="both"; 
		    fi
		    if [[ "$2" == "" ]]; then 
		    	EXPORT="both"; 
		    fi
	    ;;
	    -b|--build)
	    	BUILD="true"
	    ;;
	    -v|--vm)
	    	VM="true"
	    ;;
	    -p|--preserve)
	    	PRESERVE="true"
	    ;;
	    -h|--help)
		build_usage
	    ;;
	esac
	shift
done

echo "DEBUG: type $TYPE, export $EXPORT, build $BUILD, vm $VM, preserve $PRESERVE"

if [ "$EXPORT" != "false" -a "$VM" == "true" ]; then
	echo "Cannot run with -e and -v in the same time" 
	build_usage
fi

if [ "$TYPE" == "mng" -o "$TYPE" == "both" ]; then
	setup_mng_var
	snap_build &
fi
if [ "$TYPE" == "rh" -o "$TYPE" == "both" ]; then
	setup_rh_var
	snap_build &
fi

sleep 5
while [ -d /tmp/tmpdir_subutai ]; do
	sleep 1
done

if [ "$VM" == "true" -o "$EXPORT" != "false" ]; then
	if [ "$TYPE" == "mng" -o "$TYPE" == "both" ]; then
		setup_mng_var
		clone_vm
		install_snap
		prepare_nic
		if [ "$EXPORT" == "ova" -o "$EXPORT" == "both" ]; then
			export_ova
			echo "Exported to $EXPORT_DIR"
		fi
		if [ "$EXPORT" == "box" -o "$EXPORT" == "both" ]; then
			export_box
			echo "Exported to $EXPORT_DIR"
		fi
		if [ "$VM" == "true" ]; then
			echo "Starting vm"
			vboxmanage startvm $CLONE
		else
			vboxmanage unregistervm --delete $CLONE
		fi
	fi
	if [ "$TYPE" == "rh" -o "$TYPE" == "both" ]; then
		setup_rh_var
		clone_vm
		install_snap
		prepare_nic
		if [ "$EXPORT" == "ova" -o "$EXPORT" == "both" ]; then
			export_ova
			echo "Exported to $EXPORT_DIR"
		fi
		if [ "$EXPORT" == "box" -o "$EXPORT" == "both" ]; then
			export_box
			echo "Exported to $EXPORT_DIR"
		fi
		if [ "$VM" == "true" ]; then
			echo "Starting vm"
			vboxmanage startvm $CLONE
		else
			vboxmanage unregistervm --delete $CLONE
		fi
	fi
fi
