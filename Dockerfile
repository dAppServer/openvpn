# Use Ubuntu as the build image.
FROM lthn/ubuntu-build:20.04 as build

RUN apt-get update && apt-get install -y python-docutils python3-docutils

WORKDIR /build/lthn

# Copy source files
COPY . .

# Configure code checkout
RUN autoreconf -i -v -f

# Configure build for Linux amd64
RUN ./configure --prefix=/home/lthn

# Compile OpenVPN
RUN make -j2

RUN make install

# Use Ubuntu as the final image.
FROM ubuntu:20.04 as final

# Add Image Authors
LABEL org.opencontainers.image.authors="darbs@lethean.io,snider@lethean.io"

# Install necessary packages to run OpenVPN.
RUN apt-get update && apt-get install -y sudo openssl iptables libssl-dev libpam0g-dev liblzo2-dev

# Path where all openvpn scripts and configs will live.
WORKDIR /home/lthn/openvpn

# Copy openvpn binary
COPY --from=build --chmod=0777 /home/lthn /home/lthn
# Copy config & profile folders
COPY ./conf/ /home/lthn/openvpn/conf/
COPY ./profile/ /home/lthn/openvpn/profile/

# Copy all helper shell script files locally.
COPY --chmod=0777 ./*.sh /home/lthn/bin/
COPY ./*.conf ./

# Set Lethean environment PATH
ENV PATH=/home/lthn/bin:/home/lthn/sbin:${PATH}

# Expose the OpenVPN port
EXPOSE 1194/udp

# Set environment variables
ENV SCRIPT=""

# Run a specified  script (if provided), or run OpenVPN server if none is provided.
CMD ["/bin/bash", "-c", "if [ -f \"$SCRIPT\" ]; then \"$SCRIPT\"; else /bin/bash startup.sh; fi"]

