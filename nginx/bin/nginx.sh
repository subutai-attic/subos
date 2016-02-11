#!/bin/bash
#Include enviroment variables
. $(cd `dirname "${BASH_SOURCE[0]}"` && pwd)/subutai.env
mkdir -p $SUBUTAI_DATA_PREFIX/var/cache/nginx/
mkdir -p $SUBUTAI_DATA_PREFIX/var/log/nginx/
mkdir -p $SUBUTAI_DATA_PREFIX/var/run/
mkdir -p $SUBUTAI_DATA_PREFIX/web/ssl/
if [ "$1" == "start" ]; then
	nginx -g "daemon off;" 
else
	nginx "$@"
fi
