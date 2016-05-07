# Subutai on Snappy Ubuntu repository

This repository contains all components of Subutai Social that required to build, deploy and run SS on Snappy Ubuntu.
Content of this repo is binary files, compiled java application archives, configuration files, scripts, etc.

## Autobuild

### Description
This is a short HOW-TO document that describes process of automatic Subutai snap packages generation and test environment creation "from the scratch" using autobuild.sh script.

### Installation
Autobuild script provides different build options, such as building snaps, creating preconfigured virtual machines and exporting .ova and .box files. For each of this option, some requirements are exist.
To simply build snap packages, you only need Snappy-tools installed on your Ubuntu. To install it, run:

    sudo add-apt-repository ppa:snappy-dev/tools
    sudo apt-get update
    sudo apt-get install snappy-tools
 
If you want not just build snaps, but also automatically create preconfigured virtual machines with installed Subutai on it, you should have VirtualBox with two templates in it and sshpass utility.
Install VirtualBox and sshpass:

    sudo apt-get install virtualbox sshpass
 
**VirtualBox requires virtualization support enabled on your CPU. If you don't know what is it and how to enable it, http://askubuntu.com/a/256853 - here is the askubuntu answer**
 
Download snappy template from https://cdn.subut.ai:8338/kurjun/rest/file/get?name=snappy.ova. Double-click on snappy.ova and you'll see import dialogue. You can customize VM's configuration according to your hardware, but, do not change disks configuration. Please make sure, that virtual machines name is snappy and select existing network interface in network bridge configuration. Also, you should check "Reinitialize the MAC address of all network cards" and finish by clicking "Import".

**Do not start snappy virtual machine - this is a templates for your test servers**
 
After this you should clone Snappy Subutai repo:

    git clone git@github.com:subutai-io/Subutai-snappy.git 

When it's done, you'll have all necessary files to work with Subutai on Snappy. Directory "main" contains separated packages of Subutai on Snappy and two scripts - autobuild.sh and prepare-server.sh. We will work with autobuild.sh script.

### Autobuild usage
As we stated before, autobuild script can work in different modes. To change build modes you should specify following flags:

	-b | --build	build snap package
	-v | --vm		  create and run preconfigured virtual machine
	-e | --export	create ova or box file from our snap packages
	-p | --preserve	can be used with -v or -e flags to prevent rebuilding snap packages for virtual machine

Please note that autobuild script stores all output files in "../export" directory, i.e. next to directory main

### Examples:
**./autobuild.sh -b**	build Subutai snap package that can be installed on Snappy Ubuntu

**./autobuild.sh -v**	start new virtual machine with installed Subutai package

**./autobuild.sh -e box -p**	create Subutai vagrant box without rebuilding snap package if old one is exist

## Deploying Subutai Management server
Once you have host with installed Subutai package, you can run command

     sudo subutai import management

and after few minutes you will have your own Subutai Management server deployed and ready to create your environments. You can access Subutai Web UI in browser by typing an address https://host_ip:8443

login: admin

password: secret

You can add more Subutai hosts to this management server just by setting up new VMs in the same LAN. If you want to set up several different SS management servers in the same LAN, you need to change "MNG_VLAN" value in common/subutai.env file before build or reboot already deployed host after MNG_VLAN value update.
