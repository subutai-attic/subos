#!/bin/bash

subutai clone master management
cp subutai-4.0.0-RC6.tar.gz management.tar.gz /mnt/lib/lxc/lxc-data/management-home/subutai/
lxc-attach -n management -- mkdir -p /apps/subutai-mng /var/lib/apps/subutai-mng/current
lxc-attach -n management -- tar -C /apps/subutai-mng/ -xzf /home/subutai/subutai-4.0.0-RC6.tar.gz
lxc-attach -n management -- mv /apps/subutai-mng/subutai-4.0.0-RC6 /apps/subutai-mng/current
lxc-attach -n management -- tar -xzf /home/subutai/management.tar.gz
lxc-attach -n management -- rm -f /var/lib/dhcp/*
lxc-attach -n management -- apt update
lxc-attach -n management -- apt install --force-yes -y curl iptables iptables-persistent
modprobe iptable_nat
lxc-attach -n management -- iptables -t nat -A POSTROUTING -o eth1 -j MASQUERADE
lxc-attach -n management -- service iptables-persistent save
rm -f /mnt/lib/lxc/lxc-data/management-home/subutai/subutai-4.0.0-RC6.tar.gz
rm -f /mnt/lib/lxc/lxc-data/management-home/subutai/management.tar.gz
subutai export management
mkdir -p /mnt/lib/lxc/lxc-data/tmpdir/tmp
tar -C /mnt/lib/lxc/lxc-data/tmpdir/tmp -xzf /mnt/lib/lxc/lxc-data/tmpdir/management-subutai-template_4.0.0_amd64.tar.gz
cp config /mnt/lib/lxc/lxc-data/tmpdir/tmp
pushd /mnt/lib/lxc/lxc-data/tmpdir/tmp/
tar -czf management-subutai-template_4.0.0_amd64.tar.gz *
mv management-subutai-template_4.0.0_amd64.tar.gz ../
popd
rm -rf /mnt/lib/lxc/lxc-data/tmpdir/tmp
