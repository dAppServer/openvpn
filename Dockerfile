# Use Ubuntu as the base image
FROM ubuntu:latest

# Copy OpenVPN files locally
COPY . .

# Enable IP forwarding and promiscuous mode on interfaces
RUN echo 'net.ipv4.ip_forward=1' >> /etc/sysctl.conf \
    && echo 'net.ipv6.conf.all.disable_ipv6=0' >> /etc/sysctl.conf \
    && echo 'net.ipv6.conf.all.forwarding=1' >> /etc/sysctl.conf \
    && sysctl -p \
    && iptables -P FORWARD ACCEPT \
    && iptables -A INPUT -i eth0 -m state --state RELATED,ESTABLISHED -j ACCEPT \
    && iptables -A INPUT -i tun0 -j ACCEPT \
    && iptables -A INPUT -p udp --dport 1194 -j ACCEPT \
    && iptables -A INPUT -i tun0 -s 10.8.0.0/24 -d 127.0.0.1 -j DROP \
    && iptables -A INPUT -j DROP

USER lthn

# Copy scripts for generating certificates or profiles (optional)
RUN chmod +x generate_certs.sh
RUN chmod +x generate_client_profile.sh

# Expose the OpenVPN port
EXPOSE 1194/udp

# Run the specified startup script (if provided), or the default script if none is provided
CMD ["/bin/bash", "-c", "if [ -f ${SCRIPT} ]; then ${SCRIPT}; else "/usr/local/sbin/openvpn --config client-cert-ftm.conf"; fi"]