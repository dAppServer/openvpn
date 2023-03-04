#!/usr/bin/env bash

# Get the IP address of the disconnected client
CLIENT_IPv4=$trusted_ip

# Remove the iptables rule that blocks the client from accessing the local host
iptables -D INPUT -s $CLIENT_IPv4 -d 127.0.0.1 -j DROP
iptables -D INPUT -s $CLIENT_IPv4 -d 10.8.0.1 -j DROP