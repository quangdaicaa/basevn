systemctl enable nginx
systemctl start nginx

systemctl enable api
systemctl start api

systemctl enable docker
systemctl start docker

systemctl enable influxdb
systemctl start influxdb


echo "INFLUX_TOKEN=o2tjpLM7nXfXe3KNlaThKtEDHRJImojxwTItnB5eNUrpXail8T5-gL5hcHrnWCwWqYRET3fe3snD6ASbJmHI7g==" \
  >> /etc/default/telegraf
systemctl daemon-reload
systemctl enable telegraf
systemctl start telegraf



