#!/bin/bash
echo "system information"
echo "hostname:"
hostname -f
cat /etc/*-release
echo "ip address:"
 hostname -I
df / 

