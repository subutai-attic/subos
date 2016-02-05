#!/bin/bash

echo -e "\nGatewayPorts yes" >> /etc/ssh/sshd_config
bash -c "echo 180 > /sys/block/sda/device/timeout"
bash -c "echo 180 > /sys/block/sdb/device/timeout"
snappy install --allow-unauthenticated /home/ubuntu/tmpfs/subutai_4.0.0_amd64.snap
if [ "$(grep "gw.intra.lan" -c /etc/writable/hostname)" == "0" ]; then
        echo "rh`date +%s`.gw.intra.lan" > /etc/writable/hostname
	hostname -F /etc/writable/hostname
fi
if [ -e "/dev/sdc" ]; then 
	disk="/dev/sdc";
else 
	disk="/dev/sdb";
fi
/apps/subutai/current/bin/btrfsinit $disk

#systemctl stop snappy-autopilot.service
#systemctl disable snappy-autopilot.service
#systemctl stop snappy-autopilot.timer
#systemctl disable snappy-autopilot.timer
#mount -o remount,rw /
#rm -rf /lib/systemd/system/snappy-autopilot.timer

echo "ssh-rsa AAAAB3NzaC1yc2EAAAABIwAAAQEA6NF8iallvQVp22WDkTkyrtvp9eWW6A8YVr+kz4TjGYe7gHzIw+niNltGEFHzD8+v1I2YJ6oXevct1YeS0o9HZyN1Q9qgCgzUFtdOKLv6IedplqoPkcmF0aYet2PkEDo3MlTBckFXPITAMzF8dJSIFo9D8HfdOV0IAdx4O7PtixWKn5y2hMNG0zQPyUecp4pzC6kivAIhyfHilFR61RGL+GPXQ2MWZWFYbAGjyiYJnAmCP3NOTd0jMZEnDkbUvxhMmBYSdETk1rRgm+R4LOzFUGaHqHDLKLX+FIPKcF96hrucXzcWyLbIbEgE98OHlnVYCzRdK8jlqm8tehUc9c9WhQ== vagrant insecure public key" > /home/ubuntu/.ssh/authorized_keys
ssh-keygen -b 2048 -t rsa -f /root/.ssh/id_rsa -q -N ""
cat /root/.ssh/id_rsa.pub >> /home/ubuntu/.ssh/authorized_keys

echo "AUTOBUILD_IP=IPPLACEHOLDER" >> /apps/subutai/current/bin/subutai.env

echo "alias vi='vim.tiny'" >> /home/ubuntu/.bashrc
echo "alias vim='vim.tiny'" >> /home/ubuntu/.bashrc
echo "alias vi='vim.tiny'" >> /root/.bashrc
echo "alias vim='vim.tiny'" >> /root/.bashrc
sync
