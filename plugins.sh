#!/bin/bash

plugindir="~/Subutai/Subutai-src/plugins/"
deploydir="~/Snappy/src/main/subutai-mng/deploy/"
# Be careful, consistency is important
plugins="common-plugin hadoop-plugin zookeeper-plugin accumulo-plugin cassandra-plugin elasticsearch-plugin etl-plugin flume-plugin generic-plugin hbase-plugin hipi-plugin hive-plugin lucene-plugin mahout-plugin mongo-plugin mysql-plugin nutch-plugin oozie-plugin pig-plugin presto-plugin shark-plugin solr-plugin spark-plugin sqoop-plugin storm-plugin"


pushd plugindir
for i in $plugins; do
	if [ ! -d $i ]; then
		git clone ssh://git@stash.subutai.io:7999/ss_plugins/${i}.git
		pushd $i
	else
		pushd $i
		git pull
	fi
	mvn clean install -Dmaven.test.skip=true
	if [ "$i" == "common-plugin" ]; then
		cp target/plugin-common-4.0.0-RC3.jar $deploydir
	else
		find ./ -name "*.kar" -exec cp {} $deploydir \;
	fi	
	popd
done
popd
