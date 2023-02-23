#!/bin/bash

# Set the Common Name for the client certificate
CLIENT_NAME=$1

# Set the server public DNS record
SERVER_DNS=$2

# Read the server configuration file to get the port and protocol
SERVER_CONFIG=cert-auth-ftm.conf
SERVER_PORT=$(grep "^port " ${SERVER_CONFIG} | awk '{print $2}')
SERVER_PROTO=$(grep "^proto " ${SERVER_CONFIG} | awk '{print $2}')

# Abort client profile creation if already exists.
if [ -f profile/"$CLIENT_NAME".ovpn ]; then
    echo "Client profile "$CLIENT_NAME" already exists. Aborting."
    exit 2
fi

# Generate client profile if it does not exist.
if ! [ -f profile/"$CLIENT_NAME".ovpn ]; then

    # Write all required config to file.
    echo "client" > profile/${CLIENT_NAME}.ovpn
    echo "dev tun" >> profile/${CLIENT_NAME}.ovpn
    echo "nobind" >> profile/${CLIENT_NAME}.ovpn
    echo "remote-cert-tls server" >> profile/${CLIENT_NAME}.ovpn
    echo "remote ${SERVER_DNS} ${SERVER_PORT} ${SERVER_PROTO}" >> profile/${CLIENT_NAME}.ovpn
    echo "<ca>" >> profile/${CLIENT_NAME}.ovpn
    cat ../etc/ca/certs/ca.cert.pem >> profile/${CLIENT_NAME}.ovpn
    echo "</ca>" >> profile/${CLIENT_NAME}.ovpn
    echo "<cert>" >> profile/${CLIENT_NAME}.ovpn
    cat ../etc/ca/certs/client/${CLIENT_NAME}.cert.pem >> profile/${CLIENT_NAME}.ovpn
    echo "</cert>" >> profile/${CLIENT_NAME}.ovpn
    echo "<key>" >> profile/${CLIENT_NAME}.ovpn
    cat ../etc/ca/private/client/${CLIENT_NAME}.key.pem >> profile/${CLIENT_NAME}.ovpn
    echo "</key>" >> profile/${CLIENT_NAME}.ovpn
    echo "key-direction 1" >> profile/${CLIENT_NAME}.ovpn
    echo "<tls-auth>" >> profile/${CLIENT_NAME}.ovpn
    cat ../etc/ta.key >> profile/${CLIENT_NAME}.ovpn
    echo "</tls-auth>" >> profile/${CLIENT_NAME}.ovpn

    echo "Client profile file generated in the "profile" folder for ${CLIENT_NAME}."
fi

