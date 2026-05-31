#!/bin/bash

OPTIONS_FILE="/data/options.json"

# Check if the Home Assistant options file exists
if [ ! -f "$OPTIONS_FILE" ]; then
    echo "[Error] Home Assistant options file not found at $OPTIONS_FILE"
    exit 1
fi

# Read ac_ip from the JSON options file using jq
AC_IP=$(jq -r '.ac_ip' "$OPTIONS_FILE")

# Validate that the variable is not empty or null
if [ -z "$AC_IP" ] || [ "$AC_IP" == "null" ]; then
    echo "[Error] Could not read ac_ip from Add-on configuration."
    exit 1
fi

echo "[Info] Starting Samsung AC Proxy Engine..."
echo "[Info] Target AC IP: $AC_IP"

# 1. Generate local cert
openssl req -x509 -newkey rsa:2048 -keyout /tmp/key.pem -out /tmp/cert.pem -days 3650 -nodes -subj '/CN=localhost'
cat /tmp/cert.pem /tmp/key.pem > /etc/stunnel/server.pem

# 2. Write stunnel configuration
printf "foreground = yes\npid =\n[ssl-bridge]\naccept = 0.0.0.0:2878\nconnect = 127.0.0.1:2879\ncert = /etc/stunnel/server.pem\nclient = no\nsslVersion = TLSv1\n" > /etc/stunnel/stunnel.conf

# 3. Use the bundled certificate (already copied via Dockerfile)
CERT_FILE="/etc/ssl/ac14k_m.pem"

# 4. Start outbound socat proxy using the variable
socat -v TCP4-LISTEN:2879,fork,reuseaddr OPENSSL:$AC_IP:2878,cert=$CERT_FILE,verify=0,method=TLS1 &

# 5. Start stunnel
stunnel4 /etc/stunnel/stunnel.conf
