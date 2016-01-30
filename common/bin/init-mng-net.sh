#!/bin/bash

ovs-vsctl del-port br-int mng-lan
ovs-vsctl del-port br-mng mng-wan
exit 0
