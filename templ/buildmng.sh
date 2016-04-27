#!/bin/bash

subutai clone master management
cp subutai-*.tar.gz management.tar.gz /mnt/lib/lxc/management/home/subutai/
lxc-attach -n management -- /bin/bash -c "tar -C /opt/ -xzf /home/subutai/subutai-*.tar.gz"
lxc-attach -n management -- /bin/bash -c "mv /opt/subutai-* /opt/subutai-mng"
lxc-attach -n management -- tar -xzf /home/subutai/management.tar.gz
lxc-attach -n management -- apt update
lxc-attach -n management -- apt install --force-yes -y curl nginx
echo "echo \"server {
	listen 8339 ssl;
	ssl_certificate /opt/subutai-mng/certs/influxcert.pem;
	ssl_certificate_key /opt/subutai-mng/certs/influxkey.pem;
	proxy_connect_timeout       10;
        proxy_send_timeout          3600;
        proxy_read_timeout          3600;
        send_timeout                3600;
	location / {proxy_pass http://127.0.0.1:8333;}
}\" > /etc/nginx/sites-enabled/default" >> /mnt/lib/lxc/management/opt/subutai-mng/bin/certgen
echo "service nginx restart" >> /mnt/lib/lxc/management/opt/subutai-mng/bin/certgen
lxc-attach -n management -- sync 
lxc-attach -n management -- /bin/bash -c "rm -f /var/lib/dhcp/*"
rm -f /mnt/lib/lxc/management/home/subutai/subutai-*.tar.gz
rm -f /mnt/lib/lxc/management/home/subutai/management.tar.gz
subutai export management
