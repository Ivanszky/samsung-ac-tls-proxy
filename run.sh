#!/bin/bash
echo "[Info] Starting Samsung AC Proxy Engine..."

# 1. Generate local cert for HA -> Stunnel connection
openssl req -x509 -newkey rsa:2048 -keyout /tmp/key.pem -out /tmp/cert.pem -days 3650 -nodes -subj '/CN=localhost'
cat /tmp/cert.pem /tmp/key.pem > /etc/stunnel/server.pem

# 2. Write stunnel configuration
printf "foreground = yes\npid =\n[ssl-bridge]\naccept = 0.0.0.0:2878\nconnect = 127.0.0.1:2879\ncert = /etc/stunnel/server.pem\nclient = no\nsslVersion = TLSv1\n" > /etc/stunnel/stunnel.conf

# 3. Mount the specific AC certificate from HA shared configuration storage
CP_CERT="/etc/ssl/ac14k_m.pem"

# 4. Start outbound socat proxy to AC (ADDED: ,method=TLS1)
socat -v TCP4-LISTEN:2879,fork,reuseaddr OPENSSL:192.168.0.70:2878,cert=/etc/ssl/ac14k_m.pem,verify=0,method=TLS1 &

# 5. Start stunnel in the foreground
stunnel4 /etc/stunnel/stunnel.conf
