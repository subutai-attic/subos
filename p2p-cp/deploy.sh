#!/bin/bash

snappy build

for i in peer.noip.me 54.93.172.63 52.90.128.128 54.249.4.7; do
	scp -i ~/aws-ec2.pem p2p-cp_4.0.0_amd64.snap ubuntu@$i:~
	ssh -i ~/aws-ec2.pem "sudo snappy install --allow-unauthenticated /home/ubuntu/p2p-cp_4.0.0_amd64.snap"
done

rm p2p-cp_4.0.0_amd64.snap
