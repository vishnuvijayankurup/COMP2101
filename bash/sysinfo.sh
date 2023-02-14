#!/bin/bash

# FQDN and hostname
FQDN=$(hostname -f)
HOSTNAME=$(hostname)
# IP address
IP=$(ip route get 1.1.1.1 | awk '{print $7}')
# OS NAME 
OS=$(lsb_release -d | awk -F'\t' '{print $2}')
#space on the disk
SPACE=$(df -h / | awk '{print $4}' | sed -n 2p)
#TEMPLATE OUTPUT
TEMPLATE=$(cat << EOF
Report for $HOSTNAME
===============
FQDN: $FQDN
OPERATING SYSTEM VERSION AND NAME: $OS
IP ADDRESS: $IP
ROOT FILESYSTEM FREE SPACE: $SPACE
===============
EOF
)
#OUTPUT
echo -e "\n$TEMPLATE"

