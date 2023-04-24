#!/usr/bin/bash
openssl req -x509 -new -nodes \
  -days 90 \
  -newkey rsa:4096 \
  -keyout /etc/ssl/server.key.new \
  -out /etc/ssl/server.crt.new << EOD
VN
Hanoi
Hanoi
base.vm
base.vm
base.vm
quangnn@anninh.tv
EOD
mv -f /etc/ssl/server.key.new /etc/ssl/server.key
mv -f /etc/ssl/server.crt.new /etc/ssl/server.crt

openssl dhparam -out /etc/ssl/dhparam.pem.new 4096
mv -f /etc/ssl/dhparam.pem.new /etc/ssl/dhparam.pem

chmod -R 744 /etc/ssl
