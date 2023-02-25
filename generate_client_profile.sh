#!/bin/bash

# Set the Common Name for the client certificate
CLIENT_NAME=$1

# Set the server public DNS record
SERVER_DNS=$2

# Static defaults
LTHN_PREFIX=/home/lthn/openvpn

# Read the server configuration file to get the port and protocol
SERVER_CONFIG=cert-auth-ftm.conf
SERVER_PORT=$(grep "^port " ${SERVER_CONFIG} | awk '{print $2}')
SERVER_PROTO=$(grep "^proto " ${SERVER_CONFIG} | awk '{print $2}')

# Make profile folder if not exists
if [ ! -d profile ]; then
  mkdir -p $LTHN_PREFIX/profile
fi

# Abort client profile creation if already exists.
if [ -f profile/"$CLIENT_NAME".ovpn ]; then
    echo "Client profile "$CLIENT_NAME" already exists. Aborting."
    exit 2
fi

# Generate client profile if it does not exist.
if ! [ -f $LTHN_PREFIX/profile/"$CLIENT_NAME".ovpn ]; then

    # Write all required config to file.
    echo "client" > $LTHN_PREFIX/profile/${CLIENT_NAME}.ovpn
    echo "dev tun" >> $LTHN_PREFIX/profile/${CLIENT_NAME}.ovpn
    echo "nobind" >> $LTHN_PREFIX/profile/${CLIENT_NAME}.ovpn
    echo "remote-cert-tls server" >> $LTHN_PREFIX/profile/${CLIENT_NAME}.ovpn
    echo "remote ${SERVER_DNS} ${SERVER_PORT} ${SERVER_PROTO}" >> $LTHN_PREFIX/profile/${CLIENT_NAME}.ovpn
    echo "<ca>" >> $LTHN_PREFIX/profile/${CLIENT_NAME}.ovpn
    cat $LTHN_PREFIX/etc/ca/certs/ca.cert.pem >> $LTHN_PREFIX/profile/${CLIENT_NAME}.ovpn
    echo "</ca>" >> $LTHN_PREFIX/profile/${CLIENT_NAME}.ovpn
    echo "<cert>" >> $LTHN_PREFIX/profile/${CLIENT_NAME}.ovpn
    cat $LTHN_PREFIX/etc/ca/certs/client/${CLIENT_NAME}.cert.pem >> $LTHN_PREFIX/profile/${CLIENT_NAME}.ovpn
    echo "</cert>" >> $LTHN_PREFIX/profile/${CLIENT_NAME}.ovpn
    echo "<key>" >> $LTHN_PREFIX/profile/${CLIENT_NAME}.ovpn
    cat $LTHN_PREFIX/etc/ca/private/client/${CLIENT_NAME}.key.pem >> $LTHN_PREFIX/profile/${CLIENT_NAME}.ovpn
    echo "</key>" >> $LTHN_PREFIX/profile/${CLIENT_NAME}.ovpn
    echo "key-direction 1" >> $LTHN_PREFIX/profile/${CLIENT_NAME}.ovpn
    echo "<tls-auth>" >> $LTHN_PREFIX/profile/${CLIENT_NAME}.ovpn
    cat $LTHN_PREFIX/etc/ta.key >> $LTHN_PREFIX/profile/${CLIENT_NAME}.ovpn
    echo "</tls-auth>" >> $LTHN_PREFIX/profile/${CLIENT_NAME}.ovpn

    echo "Client profile file generated in the "profile" folder for ${CLIENT_NAME}."
fi

