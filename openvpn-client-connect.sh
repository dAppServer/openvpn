#!/bin/bash

# Get the IP address of the connected client
CLIENT_IP=$1

# Add an iptables rule to block the client from accessing the local host
iptables -I INPUT -s $CLIENT_IP -d 127.0.0.1 -j DROP
