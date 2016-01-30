# Subutai on Snappy Ubuntu repository

This repository contains all components of Subutai Social that required to build, deploy and run SS on Snappy Ubuntu.
Content of this repo is binary files, compiled java application archives, configuration files, scripts, etc.

Most common way to use this repo is to run autobuild.sh script with different flags: https://confluence.subutai.io/display/SNAP/Snappy+Subutai+autobuild+readme

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
 
Download snappy template from http://storage.critical-factor.com/index.php/s/ZeOTFbVLNnDtL2Q. Double-click on snappy.ova and you'll see import dialogue. You can customize VM's configuration according to your hardware, but, do not change disks configuration. Please make sure, that virtual machines name is snappy. Also, you should check "Reinitialize the MAC address of all network cards" and finish by clicking "Import".

**Do not start snappy virtual machine - this is a templates for our test servers**
 
After this you should clone Snappy Subutai repo from Stash: 

    git clone ssh://git@stash.subutai.io:7999/snap/main.git

When it's done, you'll have all necessary files to work with Subutai on Snappy. Directory "main" contains separated packages of Subutai on Snappy and two scripts - autobuild.sh and prepare-server.sh. We will work with autobuild.sh script.

### Autobuild usage
As we stated before, autobuild script can work in different modes. To change build modes you should specify following flags:

	-t | --type 	specify which package or VM we want - rh for resource host and mng for management server. By default, assuming both types
	-b | --build	build snap package
	-v | --vm		  create and run preconfigured virtual machine
	-e | --export	create ova or box file from our snap packages. By default, assuming both types
	-p | --preserve	can be used with -v or -e flags to prevent rebuilding snap packages for virtual machine

Please note that autobuild script stores all output files in "../export" directory, ie next to directory main

### Examples:
**./autobuild.sh**	default configuration - build rh and mng snap packages

**./autobuild.sh -t rh -b**	create snap packages for resource host

**./autobuild.sh -v**	start new virtual management server and resource host

**./autobuild.sh -t mng -e box -p**	create Management server vagrant box without rebuilding snap package if old one is exist
