#!/bin/bash

subutai clone master management
cp subutai-*.tar.gz management.tar.gz /mnt/lib/lxc/management/home/subutai/
lxc-attach -n management -- /bin/bash -c "tar -C /opt/ -xzf /home/subutai/subutai-*.tar.gz"
lxc-attach -n management -- /bin/bash -c "mv /opt/subutai-* /opt/subutai-mng"
lxc-attach -n management -- tar -xzf /home/subutai/management.tar.gz
lxc-attach -n management -- apt update
lxc-attach -n management -- apt install --force-yes -y curl
lxc-attach -n management -- sync 
lxc-attach -n management -- /bin/bash -c "rm -f /var/lib/dhcp/*"
rm -f /mnt/lib/lxc/management/home/subutai/subutai-*.tar.gz
rm -f /mnt/lib/lxc/management/home/subutai/management.tar.gz
subutai export management
