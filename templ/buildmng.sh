#!/bin/bash

subutai clone master management
sleep 2
cp subutai-4.0.0-RC6.tar.gz management.tar.gz /mnt/lib/lxc/management/home/subutai/
lxc-attach -n management -- mkdir -p /apps/subutai-mng /var/lib/apps/subutai-mng/current
lxc-attach -n management -- tar -C /apps/subutai-mng/ -xzf /home/subutai/subutai-4.0.0-RC6.tar.gz
lxc-attach -n management -- mv /apps/subutai-mng/subutai-4.0.0-RC6 /apps/subutai-mng/current
lxc-attach -n management -- tar -xzf /home/subutai/management.tar.gz
lxc-attach -n management -- rm -f /var/lib/dhcp/*
lxc-attach -n management -- apt update
lxc-attach -n management -- apt install --force-yes -y curl
rm -f /mnt/lib/lxc/management/home/subutai/subutai-4.0.0-RC6.tar.gz
rm -f /mnt/lib/lxc/management/home/subutai/management.tar.gz
subutai export management
