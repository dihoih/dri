#! /bin/bash

mkdir drive_server
cd drive_server

cat <<EOF >conf.ini
[System]
Debug = false
Mode = master
Listen = cloudreve.org:80
SessionSecret = FSHhAbo12zdO1aqloqHWcUDo720bmcnq3mTGTc907DYRgExgGYJGTtJ5G306Zm0m
HashIDSalt = Jd6Sob58ZiLJUHCAg21auwjQ9hGo5BoARofmeX9SvsTgRJE2bSnASxaCiIzpjDQy

[SSL]
Listen = cloudreve.org:443
CertPath = /root/drive_server/tls/cert.pem
KeyPath = /root/drive_server/tls/private.pem
EOF

cat <<EOF >/usr/lib/systemd/system/cloudreve.service
[Unit]
Description=Cloudreve
Documentation=https://docs.cloudreve.org
After=network.target
After=mysqld.service
Wants=network.target

[Service]
WorkingDirectory=/root/drive_server
ExecStart=/root/drive_server/cloudreve
Restart=on-abnormal
RestartSec=5s
KillMode=mixed

StandardOutput=null
StandardError=syslog

[Install]
WantedBy=multi-user.target
EOF

curl -L "https://github.com/cloudreve/Cloudreve/tags/" -o $(mktemp -d)/web_page
var=`grep -m 1 /cloudreve/Cloudreve/releases/tag/ $(mktemp -d)/web_page|awk -F ">" '{print $3}'|awk -F '<' '{print $1}'`
curl --retry 10 --retry-max-time 60 -H "Cache-Control: no-cache" -fsSL github.com/cloudreve/Cloudreve/releases/download/${var}/cloudreve_${var}_linux_amd64.tar.gz -o ./cloudreve.tar.gz
tar -zxvf cloudreve.tar.gz

chmod +x ./cloudreve

mkdir /root/drive_server/tls
(umask 077; openssl genrsa -out /root/drive_server/tls/private.pem 2048)
openssl req -new -x509 -key /root/drive_server/tls/private.pem -out /root/drive_server/tls/cert.pem -days 365 -subj "/C=US/ST=California/L=San Francisco/OU=Cloud/CN=cloudreve.org"


echo 0.0.0.0 cloudreve.org>>/etc/hosts

systemctl daemon-reload
systemctl enable cloudreve.service
systemctl start cloudreve.service
./cloudreve

