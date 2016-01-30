#!/bin/bash
#Include enviroment variables
. $(cd `dirname "${BASH_SOURCE[0]}"` && pwd)/subutai.env
mkdir -p /var/lib/apps/subutai-mng/current/var/cache/nginx/
mkdir -p /var/lib/apps/subutai-mng/current/var/log/nginx/
mkdir -p /var/lib/apps/subutai-mng/current/var/run/
nginx -g "daemon off;"
