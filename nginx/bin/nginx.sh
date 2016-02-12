#!/bin/bash
#Include enviroment variables
. $(cd `dirname "${BASH_SOURCE[0]}"` && pwd)/subutai.env
mkdir -p $SUBUTAI_DATA_PREFIX/var/cache/nginx/
mkdir -p $SUBUTAI_DATA_PREFIX/var/log/nginx/
mkdir -p $SUBUTAI_DATA_PREFIX/var/run/
mkdir -p $SUBUTAI_DATA_PREFIX/web/ssl/
while [ $(ping 8.8.8.8 -c1 | grep -c "1 received") -ne 1 ]; do
        sleep 1
done
if [ "$1" == "start" ]; then
        nginx -g "daemon off;"
else
        nginx "$@"
fi
