# Subutai on Snappy Ubuntu repository

This repository contains all components of Subutai Social that required to build, deploy and run SS in Linux.
Content of this repo is binary files, compiled java application archives, configuration files, scripts, etc.

## Autobuild

### Description
This is a short HOW-TO document that describes process of automatic Subutai snap packages generation and test environment creation "from the scratch" using autobuild.sh script.
Steps below describes build process for Ubuntu operating system. Other distributions might face compatibility issues.

### Installation
Autobuild script provides different build options, such as building snaps, creating preconfigured virtual machines and exporting .ova and .box files. There are different pre-requirements for each of these options.
To simply build snap packages, you only need Snappy-tools installed on your Ubuntu. To install it, run:

    sudo add-apt-repository ppa:snappy-dev/tools
    sudo apt-get update
    sudo apt-get install snappy-tools
 
If you want not just build snaps, but also automatically create preconfigured virtual machines with installed Subutai on it, you should have VirtualBox with Snappy template imported and sshpass utility.
Install VirtualBox and sshpass:

    sudo apt-get install virtualbox sshpass
 
**VirtualBox requires virtualization support enabled on your CPU. If you don't know what is it and how to enable it, http://askubuntu.com/a/256853 - here is the askubuntu answer**
 
Download snappy template from https://cdn.subut.ai:8338/kurjun/rest/file/get?name=snappy.ova. Double-click on snappy.ova and you'll see import dialogue. You can customize VM's configuration according to your hardware, but, do not change disks configuration. Please make sure, that network bridge configuration is set to existing in your system network interface. Also, you should check "Reinitialize the MAC address of all network cards" and finish by clicking "Import".

**Do not start snappy virtual machine - this is a templates for your test servers**
 
After this you should clone Snappy Subutai repo:

    git clone https://github.com/subutai-io/subos.git 

When it's done, you'll have all necessary files to work with Subutai Social. Directory "main" contains separated packages of Subutai and "autobuild.sh" script.

### Autobuild usage
As we stated before, autobuild can work in different modes. To change build modes you should specify following flags:

	-b | --build	build snap package
	-v | --vm	create and run preconfigured virtual machine
	-t | --tag	this flag is used with "-v" option to specify VM's VLAN tag. This is needed to build more than one Subutai peer in the same LAN
	-e | --export	export ova or box image with Subutai Social

Please note that autobuild script stores all generated files in "../export" directory, i.e. next to main repository directory 

### Examples:
**./autobuild.sh -b**	build Subutai snap package that can be installed on Snappy Ubuntu

**./autobuild.sh -v**	start new virtual machine with installed Subutai package, default VLAN tag is 2

**./autobuild.sh -e box**	create Subutai vagrant box

## Deploying Subutai Management server
Once you have virtual machine prepared with "./autobuild.sh -v" command, you can deploy management server on it simply by running

     sudo subutai import management

and after few minutes your own Subutai management server will be ready to serve.

You can add more Subutai hosts to this management server by setting up new VMs with same VLAN tag. If you want to set up several separated management servers in the same LAN, you should run autobuild script with specifying different VLAN tags.
