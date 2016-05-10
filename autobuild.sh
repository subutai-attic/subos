#!/bin/bash

set -e

# Script usage
function build_usage {
	echo -e "\nBuild, install and export Subutai Snappy"
	echo -e "\nusage:"
	echo "$0 -e|--export OUTPUT or v|--vm [ -p|--preserve ] or -b|--build -t|--tag"
	echo "Arguments:"
	echo "	-d|--deploy DEB		- deploy peers according to config in ~/.peer.conf or ./.peer.conf and install DEB inside SS management"
	echo "	-e|--export OUTPUT	- type of output file: \"ova\", \"box\" or \"both\". Assuming both by default. This option will rebuild temporary snap"
	echo "	-b|--build		- just build snap package"
	echo "	-v|--vm			- create and run preconfigured virtual machine. This command will rebuild temporary snap package and install it inside the VM"
	echo "	-t|--tag		- setup Subutai Management VLAN tag. By default it is 200"
	echo "	-h|--help		- show this text"
	echo "	-bridge			- Create VM with bridged network"
	echo -e "\n"

	exit 0
}

function snap_build {
	rm -rf /tmp/tmpdir_subutai
	mkdir -p /tmp/tmpdir_subutai
	for i in $LIST; do
		cp -r $i/* /tmp/tmpdir_subutai
	done
	sed -i /tmp/tmpdir_subutai/meta/package.yaml -e "s/TIMESTAMP/$DATE/g"
	if [ "$TAG" != "" ]; then
		sed -i /tmp/tmpdir_subutai/bin/init-br -e "s/MNG_VLAN=2/MNG_VLAN=$TAG/g"
		sed -i /tmp/tmpdir_subutai/bin/create_ovs_interface -e "s/MNG_VLAN=2/MNG_VLAN=$TAG/g"
	fi
	echo "Building Subutai snap"
	if [ "$(which snappy)" == "" ]; then
		pushd /tmp
		tar czf /tmp/snap.tgz tmpdir_subutai
		popd
		sshpass -p "ubuntu" scp -P4567 /tmp/snap.tgz ubuntu@localhost:/home/ubuntu/tmpfs/
		sshpass -p "ubuntu" ssh -o StrictHostKeyChecking=no ubuntu@localhost -p4567 "cd /home/ubuntu/tmpfs && tar zxf snap.tgz && cd tmpdir_subutai && snappy build && mv *.snap .."
		if [ "$BUILD" == "true" ]; then
			mkdir -p $EXPORT_DIR/snap
			sshpass -p "ubuntu" scp -P4567 ubuntu@localhost:/home/ubuntu/tmpfs/subutai*.snap $EXPORT_DIR/snap
		else
			sshpass -p "ubuntu" scp -P4567 ubuntu@localhost:/home/ubuntu/tmpfs/subutai*.snap /tmp
		fi
	elif [ "$BUILD" == "true" ]; then
		snappy build "/tmp/tmpdir_subutai" --output=$EXPORT_DIR/snap
	else
		snappy build "/tmp/tmpdir_subutai" --output=/tmp
	fi
	rm -rf /tmp/tmpdir_subutai
}


function clone_vm {
	echo "Creating clone"
	vboxmanage clonevm --register --name $CLONE snappy 
	vboxmanage modifyvm $CLONE --nic1 none
	vboxmanage modifyvm $CLONE --nic2 none
	vboxmanage modifyvm $CLONE --nic3 none
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
	if [ "$(which snappy)" == "" ]; then
		snap_build
	fi
	sshpass -p "ubuntu" scp -P4567 prepare-server.sh /tmp/subutai_4.0.0-${DATE}_amd64.snap ubuntu@localhost:/home/ubuntu/tmpfs/
	AUTOBUILD_IP=$(ifconfig `route -n | grep ^0.0.0.0 | awk '{print $8}'` | grep 'inet addr' | awk -F: '{print $2}' | awk '{print $1}') 
	sshpass -p "ubuntu" ssh -o StrictHostKeyChecking=no ubuntu@localhost -p4567 "sed -i \"s/IPPLACEHOLDER/$AUTOBUILD_IP/g\" /home/ubuntu/tmpfs/prepare-server.sh"
	echo "Running install script"
	sshpass -p "ubuntu" ssh -o StrictHostKeyChecking=no ubuntu@localhost -p4567 "sudo /home/ubuntu/tmpfs/prepare-server.sh"
}

function prepare_nic {
	echo "Shutting down vm"
	vboxmanage controlvm $CLONE poweroff
	echo "Restoring network"
	sleep 3

	if [ "$(vboxmanage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1 >/dev/null; echo $?)" == "1" ]; then
		vboxmanage hostonlyif create
		vboxmanage hostonlyif ipconfig vboxnet0 --ip 192.168.56.1
		vboxmanage dhcpserver add --ifname vboxnet0 --ip 192.168.56.1 --netmask 255.255.255.0 --lowerip 192.168.56.100 --upperip 192.168.56.200
		vboxmanage dhcpserver modify --ifname vboxnet0 --enable
	fi

	vboxmanage modifyvm $CLONE --nic4 none
	vboxmanage modifyvm $CLONE --nic3 none
        if [ "$BRIDGEMODE" == "true" ]; then
		vboxmanage modifyvm $CLONE --nic2 none
		vboxmanage modifyvm $CLONE --nic1 bridged
	else
		vboxmanage modifyvm $CLONE --nic2 hostonly
		vboxmanage modifyvm $CLONE --hostonlyadapter2 vboxnet0
	        vboxmanage modifyvm $CLONE --nic1 nat
	fi
}

function export_ova {
	echo "Exporting OVA image"
	mkdir -p "$EXPORT_DIR/ova"
	vboxmanage export $CLONE -o $EXPORT_DIR/ova/${CLONE}.ova --ovf20
}

function export_box {
	mkdir -p "$EXPORT_DIR/vagrant/"
	local dst="$EXPORT_DIR/vagrant/"

	echo "Exporting Vagrant box"
	vagrant init $CLONE ${CLONE}.box	
	vagrant package --base $CLONE --output $dst/${CLONE}.box
	
	mv -f Vagrantfile .vagrant $dst

	# inject.vagrant parameters into Vagrantfile
	sed -e '/# config.vm.network "public_network"/ {' \
		-e 'r inject.vagrant' -e 'd' -e '}' -i $dst/Vagrantfile
}

function setup_var {
        LIST="btrfs collectd curl lxc ovs rh rngd subutai cgmanager p2p dnsmasq nginx lxcfs"
       	CLONE=subutai-"$DATE"
}

BRIDGEMODE="false"
EXPORT="false"
BUILD="false"
CONF="false"
VM="false"
EXPORT_DIR="../export"
DATE="$(date +%s)"

if [ "$#" == "0" ]; then VM="true"; fi

while [ $# -ge 1 ]; do
	key="$1"

	case $key in
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
	    -bridge)
		BRIDGEMODE="true"
	    ;;
	    -d|--deploy)
		if [[ -f ~/.peer.conf ]]; then
			CONF=~/.peer.conf
		elif [[ -f ./.peer.conf ]]; then
			CONF=./.peer.conf
		else
			echo ".peer.conf file not found"
			exit 1
		fi
		if [[ -f "$2" ]]; then
			DEB="$2"
			shift
		fi
	    ;;
	    -v|--vm)
	    	VM="true"
	    ;;
	    -t|--tag)
		TAG="$2"
		shift
	    ;;
	    -h|--help)
		build_usage
	    ;;
	esac
	shift
done

setup_var
if [ "$(which snappy)" == "" ]; then
	VM="true"
else
	snap_build
fi

if [ "$VM" == "true" -o "$EXPORT" != "false" ]; then
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
		vboxmanage startvm --type headless $CLONE
		echo "Waiting for Subutai IP address"
		echo -e "Please use following command to access your new Subutai:\\n ssh root@`nc -l 48723`"
	else
		vboxmanage unregistervm --delete $CLONE
	fi

elif [ "$CONF" != "false" ]; then
	peer=$(grep PEER $CONF | cut -d"=" -f2)
	rh=$(grep RH $CONF | cut -d"=" -f2)

	if [ "$peer" == "" ] || [ "$rh" == "" ]; then
		echo "Invalid config"
		exit 1
	fi

	echo "Erecting $peer(x${rh}RH) peer. Please wait"

	i=0
	while [ $i -lt $peer ]; do
		j=0
		vlan=$(shuf -i 1-4096 -n 1)
		while [ $j -lt $rh ]; do
			mhip=$($0 -v -t $vlan | grep "root@" | cut -d"@" -f2)
			if [ $j -eq 0 ]; then 
				ssh-keygen -f ~/.ssh/known_hosts -R $mhip
				ssh -o StrictHostKeyChecking=no root@$mhip "/apps/subutai/current/bin/subutai import management"			
				if [ "$DEB" != "" ]; then
					sshpass -p "ubuntu" scp -o StrictHostKeyChecking=no -P2222 $DEB root@$mhip:~
					sshpass -p "ubuntu" ssh	-o StrictHostKeyChecking=no -p2222 root@$mhip "dpkg -i ~/$(basename $DEB)"
				fi
				arr[$i]=$mhip
			fi
			let "j=j+1"
		done
		let "i=i+1"
	done

	echo -e "\\nManagement IPs: ${arr[*]}"
fi
