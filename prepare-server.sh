#!/bin/bash

echo -e "\nGatewayPorts yes" >> /etc/ssh/sshd_config
bash -c "echo 180 > /sys/block/sda/device/timeout"
bash -c "echo 180 > /sys/block/sdb/device/timeout"
if [ "$(grep "gw.intra.lan" -c /etc/writable/hostname)" == "0" ]; then
        hostnamectl set-hostname "rh`date +%s`.gw.intra.lan" 
fi
snappy install --allow-unauthenticated /home/ubuntu/tmpfs/subutai_4.*_amd64.snap
if [ -e "/dev/sdc" ]; then 
	disk="/dev/sdc";
else 
	disk="/dev/sdb";
fi
/apps/subutai/current/bin/btrfsinit $disk

systemctl stop snappy-autopilot.service
systemctl disable snappy-autopilot.service
systemctl stop snappy-autopilot.timer
systemctl disable snappy-autopilot.timer
mount -o remount,rw /
rm -rf /lib/systemd/system/snappy-autopilot.timer

ssh-keygen -b 2048 -t rsa -f /root/.ssh/id_rsa -q -N ""
cat /root/.ssh/id_rsa.pub >> /home/ubuntu/.ssh/authorized_keys

echo "AUTOBUILD_IP=IPPLACEHOLDER" >> /apps/subutai/current/bin/subutai.env

echo "alias vi='vim.tiny'" >> /home/ubuntu/.bashrc
echo "alias vim='vim.tiny'" >> /home/ubuntu/.bashrc
echo "alias vi='vim.tiny'" >> /root/.bashrc
echo "alias vim='vim.tiny'" >> /root/.bashrc
sync
