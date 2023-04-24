# ----------------------------------------
# Install InfluxDB
# ----------------------------------------
wget -O /tmp/influxdb.deb \
  https://dl.influxdata.com/influxdb/releases/influxdb2-2.0.9-amd64.deb
dpkg -i /tmp/influxdb.deb

rm -rf /tmp/*
dmesg --clear
history -c
reboot

cat > /etc/nginx/avaiable/influxdb.conf << EOF
server {
  listen 8888 so_keepalive=on;
  proxy_socket_keepalive on;
  proxy_pass localhost:8086;
}

EOF
ln -s /etc/nginx/avaiable/influxdb.conf /etc/nginx/stream

