#!/bin/bash

# Enable IP forwarding and promiscuous mode
echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf && \
echo 'net.ipv4.conf.all.promisc=1' >> /etc/sysctl.conf && \
sysctl -p

# Create iptables rules to deny VPN users access to localhost
iptables -I FORWARD -s 10.8.0.0/24 -d 127.0.0.0/8 -j REJECT && \
iptables-save > /etc/iptables.rules

# Run OpenVPN server with iptables setup.
openvpn --config client-cert-ftm.conf --iptables iptables-restore < /etc/iptables.rules