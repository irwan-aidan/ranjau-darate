#!/bin/bash

wget -q -nc https://github.com/p4gefau1t/trojan-go/releases/download/v0.9.0/trojan-go-linux-amd64.zip
if [ ! -f trojan-go ]
then
	unzip trojan-go-linux-amd64.zip
fi
cp trojan-go /usr/bin
cat << EOF > /etc/trojan-go/trojan-go.json
{
    "run_type": "server",
    "local_addr": "0.0.0.0",
    "local_port": 8443,
    "remote_addr": "127.0.0.1",
    "remote_port": 80,
    "password": [
        "$PASSWORD"
    ],
    "ssl": {
        "cert": "",
        "key": "",
        "sni": "",
        "fallback_addr": "127.0.0.1",
        "fallback_port": 80
    },
    "websocket": {
        "enabled": true,
        "path": "/bokir",
        "host": "$HOST",
        "obfuscation_password": "$PASSWORD",
        "double_tls": false
    }
}
EOF
cat << EOF > /etc/systemd/system/trojan-go.service
[Unit]
Description=Trojan-Go - An unidentifiable mechanism that helps you bypass GFW
Documentation=https://github.com/p4gefau1t/trojan-go
After=network.target nss-lookup.target
Wants=network-online.target
[Service]
Type=simple
User=root
ExecStart=/usr/bin/trojan-go -config /etc/trojan-go/trojan-go.json
Restart=on-failure
RestartSec=10
RestartPreventExitStatus=23
[Install]
WantedBy=multi-user.target
EOF
systemctl enable --now trojan-go
systemctl restart trojan-go