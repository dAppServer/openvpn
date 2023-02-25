#!/bin/bash

# Get the IP address of the disconnected client
CLIENT_IP=$1

# Remove the iptables rule that blocks the client from accessing the local host
iptables -D INPUT -s $CLIENT_IP -d 127.0.0.1 -j DROP
