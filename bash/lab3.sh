#!/bin/bash

# Verify whether lxd is present, and if not, install it.
if ! command -v lxd &> /dev/null
then
    sudo apt-get update
    sudo snap install lxd
fi

# determine whether the lxdbr0 bridge already exists and create it if required.
if ! ip link show lxdbr0 &> /dev/null
then
    sudo lxd init --auto
fi

# verify the existence of the container and create it if required
if ! lxc info COMP2101-S22 &> /dev/null
then
    lxc launch ubuntu:20.04 COMP2101-S22
fi

# Get the IP address of the container and update /etc/hosts as needed 
ip_addr=$(lxc list COMP2101-S22 --format=json | jq -r '.[0].state.network.eth0.addresses[] | select(.family=="inet").address')
if ! grep -q "COMP2101-S22" /etc/hosts || ! grep -q "$ip_addr" /etc/hosts
then
    echo "$ip_addr COMP2101-S22" | sudo tee -a /etc/hosts
fi

# if required, install Apache2 in the container
if ! lxc exec COMP2101-S22 -- command -v apache2 &> /dev/null
then
    lxc exec COMP2101-S22 -- apt-get update
    lxc exec COMP2101-S22 -- apt-get install -y apache2
fi

# Obtain the container's default web page, and then inform the user of achievement or failure.
response=$(curl -s -o /dev/null -w "%{http_code}" http://COMP2101-S22)
if [ $response -eq 200 ]
then
    echo "Successfully retrieved default web page from container's web service"
else
    echo "Failed to retrieve default web page from container's web service"
fi
