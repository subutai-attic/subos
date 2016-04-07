#!/bin/bash

snappy build

for i in peer.noip.me 52.59.251.179 52.90.197.198 54.183.100.182; do
	scp -P8022 -i ~/aws-ec2.pem p2p-cp_4.0.0_amd64.snap ubuntu@$i:~
	ssh -p8022 -i ~/aws-ec2.pem ubuntu@$i "sudo snappy install --allow-unauthenticated /home/ubuntu/p2p-cp_4.0.0_amd64.snap"
done

rm p2p-cp_4.0.0_amd64.snap
