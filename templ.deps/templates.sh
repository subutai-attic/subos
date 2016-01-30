#!/bin/bash

subutai destroy master
subutai import master
subutai demote master
subutai start master
lxc-attach -n master -- dhclient eth0 && sleep 2
lxc-attach -n master -- sed -i '/9999/d' /etc/apt/sources.list.d/subutai-repo.list
lxc-attach -n master -- apt update
lxc-attach -n master -- apt upgrade -y
lxc-attach -n master -- apt-get clean
lxc-attach -n master -- apt-get autoremove -y 
subutai export master


subutai destroy openjre7 
subutai clone master openjre7
lxc-attach -n openjre7 -- dhclient eth0 && sleep 2 
lxc-attach -n openjre7 -- apt update
lxc-attach -n openjre7 -- apt install -y openjdk-7-jre-headless  
lxc-attach -n openjre7 -- apt-get clean
lxc-attach -n openjre7 -- apt-get autoremove -y 
subutai export openjre7 


subutai destroy hadoop 
subutai clone openjre7 hadoop
lxc-attach -n hadoop -- dhclient eth0 && sleep 2
lxc-attach -n hadoop -- apt update
lxc-attach -n hadoop -- apt install --force-yes -y subutai-hadoop 
lxc-attach -n hadoop -- apt-get clean
lxc-attach -n hadoop -- apt-get autoremove -y 
subutai export hadoop 


subutai destroy cassandra
subutai clone openjre7 cassandra
lxc-attach -n cassandra -- dhclient eth0 && sleep 2
lxc-attach -n cassandra -- apt update
lxc-attach -n cassandra -- apt install --force-yes -y subutai-cassandra
lxc-attach -n cassandra -- apt-get clean
lxc-attach -n cassandra -- apt-get autoremove -y 
subutai export cassandra


subutai destroy zookeeper
subutai clone openjre7 zookeeper
lxc-attach -n zookeeper -- dhclient eth0 && sleep 2
lxc-attach -n zookeeper -- apt update
lxc-attach -n zookeeper -- apt install --force-yes -y subutai-zookeeper
lxc-attach -n zookeeper -- apt-get clean
lxc-attach -n zookeeper -- apt-get autoremove -y 
subutai export zookeeper


subutai destroy solr
subutai clone openjre7 solr
lxc-attach -n solr -- dhclient eth0 && sleep 2
lxc-attach -n solr -- apt update
lxc-attach -n solr -- apt install --force-yes -y subutai-solr
lxc-attach -n solr -- apt-get clean
lxc-attach -n solr -- apt-get autoremove -y 
subutai export solr


subutai destroy storm
subutai clone openjre7 storm
lxc-attach -n storm -- dhclient eth0 && sleep 2
lxc-attach -n storm -- apt update
lxc-attach -n storm -- apt install --force-yes -y subutai-storm
lxc-attach -n storm -- apt-get clean
lxc-attach -n storm -- apt-get autoremove -y 
subutai export storm


subutai destroy mongo
subutai clone master mongo
lxc-attach -n mongo -- dhclient eth0 && sleep 2
lxc-attach -n mongo -- apt update
lxc-attach -n mongo -- apt install -y wget
lxc-attach -n mongo -- wget https://s3.eu-central-1.amazonaws.com/subutai-repo/apt/subutai-mongo_1.0.4_all.deb
lxc-attach -n mongo -- apt install --force-yes -y mongodb-10gen 
lxc-attach -n mongo -- dpkg -i subutai-mongo_1.0.4_all.deb
lxc-attach -n mongo -- apt remove -y wget 
lxc-attach -n mongo -- rm -rf subutai-mongo_1.0.4_all.deb 
lxc-attach -n mongo -- apt-get clean
lxc-attach -n mongo -- apt-get autoremove -y 
subutai export mongo


subutai destroy elasticsearch
subutai clone openjre7 elasticsearch
lxc-attach -n elasticsearch -- dhclient eth0 && sleep 2
lxc-attach -n elasticsearch -- apt update
lxc-attach -n elasticsearch -- apt install --force-yes -y subutai-elasticsearch
lxc-attach -n elasticsearch -- apt-get clean
lxc-attach -n elasticsearch -- apt-get autoremove -y 
subutai export elasticsearch


subutai destroy webdemo 
subutai clone master webdemo
cp /home/ubuntu/webdemo.tgz /mnt/lib/lxc/webdemo/rootfs/
lxc-attach -n webdemo -- tar zxf /webdemo.tgz -C /
rm -rf /mnt/lib/lxc/webdemo/rootfs/webdemo.tgz
subutai export webdemo 


