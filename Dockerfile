# Use Ubuntu as the base image.
FROM ubuntu:20.04

# Path where all openvpn scripts and configs will live.
WORKDIR /home/lthn/openvpn

# Copy all required files locally.
COPY . .

# Install necessary packages and prepare binary location.
RUN apt-get update && apt-get install -y sudo openssl iptables liblzo2-dev libpam0g-dev \
    && mkdir -p /home/lthn/bin \
    && mv bin/sbin/openvpn ../bin/openvpn \
    && export PATH=/home/lthn/bin:$PATH

# Gives rights to run scripts for generating certificates, client profiles, setup of ip forwarding, promiscuous mode,  iptables (minimum) and running openvpn server.
RUN chmod +x generate_certs.sh generate_client_profile.sh startup.sh

# Expose the OpenVPN port
EXPOSE 1194/udp

# Set environment variables
ENV SCRIPT=""

# Run a specified  script (if provided), or run OpenVPN server if none is provided.
CMD ["/bin/bash", "-c", "if [ -f \"$SCRIPT\" ]; then \"$SCRIPT\"; else /bin/bash startup.sh; fi"]

