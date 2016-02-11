#!/bin/bash
sshpass -p "ubuntu" ssh -p2222 -o StrictHostKeyChecking=no root@$1  "echo start"
sshpass -p "ubuntu" scp -P2222 subutai*.tar.gz  root@$1:/root
sshpass -p "ubuntu" ssh -p2222 root@$1 "service management stop"
sshpass -p "ubuntu" ssh -p2222 root@$1 "tar xf /root/subutai*.tar.gz -C /root/"
sshpass -p "ubuntu" ssh -p2222 root@$1 "rm -rf /root/subutai*.tar.gz"
sshpass -p "ubuntu" ssh -p2222 root@$1 "rm -rf /var/lib/apps/subutai-mng/current/*"
sshpass -p "ubuntu" ssh -p2222 root@$1 "cp -a /root/subutai*/system /root/subutai*/lib /root/subutai*/deploy /root/subutai*/etc /apps/subutai-mng/current/"
sshpass -p "ubuntu" ssh -p2222 root@$1 "rm -rf /root/subutai*"
sshpass -p "ubuntu" ssh -p2222 root@$1 "service management start"


