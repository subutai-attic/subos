#!/bin/bash

for i in peer.noip.me eu0.cdn.subut.ai us0.cdn.subut.ai us1.cdn.subut.ai; do
	scp -P8022 -i ~/aws-ec2.pem p2p-cp_4.0.0_amd64.snap ubuntu@$i:~
	ssh -p8022 -i ~/aws-ec2.pem ubuntu@$i "sudo snappy install --allow-unauthenticated /home/ubuntu/p2p-cp_4.0.0_amd64.snap"
done

rm p2p-cp_4.0.0_amd64.snap
