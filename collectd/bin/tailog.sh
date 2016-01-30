#!/bin/bash

tail -n0 -F /var/lib/apps/subutai-mng/0.0.1/lighttpd-access.log | \
while read LINE
do
	query=$(echo $LINE | awk '{print $1" "$2}')
	curl -s -i -XPOST 'http://localhost:8086/write?db=metrics' --data-binary "$query" > /dev/null 2>&1
done
