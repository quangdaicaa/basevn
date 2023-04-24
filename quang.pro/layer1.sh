mkdir -pv /data
mkdir -pv /log
mkdir -pv /code

cat > /etc/hostname << EOF
quangpro
EOF

cat > /etc/hosts << EOF
127.0.0.1   localhost
103.142.139.222   quang.pro

EOF


cat > /etc/apt/sources.list << EOF
deb http://vn.archive.ubuntu.com/ubuntu jammy main restricted universe multiverse
deb http://vn.archive.ubuntu.com/ubuntu jammy-updates main restricted universe multiverse
deb http://vn.archive.ubuntu.com/ubuntu jammy-backports main restricted universe multiverse
deb http://vn.archive.ubuntu.com/ubuntu jammy-security main restricted universe multiverse
deb https://mirrors.bkns.vn/ubuntu/ jammy main

EOF


rm -rf /etc/resolv.conf
cat > /etc/resolv.conf << EOF
nameserver 1.1.1.1
nameserver 8.8.8.8

EOF
chmod 444 /etc/resolv.conf

cat > /etc/ssh/sshd_config << EOF
KbdInteractiveAuthentication no
UsePAM yes
X11Forwarding yes
AcceptEnv LANG LC_*
Subsystem sftp	/usr/lib/openssh/sftp-server
PasswordAuthentication no
PubkeyAuthentication yes
AuthorizedKeysFile .ssh/authorized_keys
PrintMotd no
Port 22

EOF

apt update
apt install -y \
  curl wget unzip \
  apt-transport-https software-properties-common tzdata \
  gnupg2 ca-certificates lsb-release debian-archive-keyring

apt update
apt purge -y locales
apt install -y locales
locale-gen en_US.UTF-8 en_US
update-locale LC_ALL=en_US.UTF-8 LANG=en_US.UTF-8

apt update
apt install -y \
  openssh-server git tree lunar htop net-tools iputils-ping

apt update
apt install -y nano
curl https://raw.githubusercontent.com/scopatz/nanorc/master/install.sh | bash
echo "set tabsize 2" >> /etc/nanorc

cat >> /etc/profile << EOF
export TZ=Asia/Ho_Chi_Minh
export PATH=/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/sbin:/bin
EOF
source /etc/profile

rm -fv /etc/localtime
ln -s /usr/share/zoneinfo/Asia/Ho_Chi_Minh /etc/localtime

rm -rfv /usr/games
rm -rfv /usr/local/games
apt autoremove -y --purge snapd
apt-mark hold snapd

rm -rf /etc/update-motd.d
cat > /etc/motd << EOF
    ____                                    
   / __ )____ _________          _   ______ 
  / __  / __ \`/ ___/ _ \        | | / / __ \\
 / /_/ / /_/ (__  )  __/  _     | |/ / / / /
/_____/\__,_/____/\___/  (_)    |___/_/ /_/ 

EOF

systenctl daemon-reload
systemctl disable ufw

sed -i '/swap/d' /etc/fstab
swapoff -a

apt upgrade -y
apt autoremove -y
apt clean

rm -rf /tmp/*
dmesg --clear
history -c
reboot


# ----------------------------------------
# Install Telegraf
# ----------------------------------------
wget -O /tmp/influxdata.key \
  https://repos.influxdata.com/influxdata-archive_compat.key
echo '393e8779c89ac8d958f81f942f9ad7fb82a25e133faddaf92e15b16e6ac9ce4c /tmp/influxdata.key' \
  | sha256sum -c && cat /tmp/influxdata.key \
  | gpg --dearmor \
  > /etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg
echo "deb [signed-by=/etc/apt/trusted.gpg.d/influxdata-archive_compat.gpg] \
  https://repos.influxdata.com/debian stable main" \
  > /etc/apt/sources.list.d/telegraf.list

apt update
apt install -y telegraf
apt upgrade -y
apt autoremove -y
apt clean

cat > /etc/telegraf/telegraf.conf << EOF
[agent]
  interval = "10s"
  round_interval = true
  metric_batch_size = 1000
  metric_buffer_limit = 10000
  collection_jitter = "0s"
  flush_interval = "10s"
  flush_jitter = "0s"

[[outputs.influxdb_v2]]
  urls = ["http://quang.pro:8888"]
  token = "\$INFLUX_TOKEN"
  organization = "base.vm"
  bucket = "telegraf"

[[inputs.cpu]]
  percpu = true
  totalcpu = true
  collect_cpu_time = false
  report_active = false
  core_tags = false

[[inputs.disk]]
  ignore_fs = ["tmpfs", "devtmpfs", "devfs", "iso9660", "overlay", "aufs", "squashfs"]

[[inputs.diskio]]
[[inputs.mem]]
[[inputs.net]]
[[inputs.processes]]
[[inputs.system]]

[[inputs.docker]]	
  endpoint = "unix:///var/run/docker.sock"
  gather_services = false
  container_names = []
  container_name_include = []
  container_name_exclude = []
  timeout = "5s"
  perdevice = true
  total = false
  docker_label_include = []
  docker_label_exclude = []

EOF

systemctl daemon-reload
systemctl disable telegraf


# ----------------------------------------
# Install Docker
# ----------------------------------------
curl -fsSL https://download.docker.com/linux/ubuntu/gpg \
  | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) \
  signed-by=/etc/apt/keyrings/docker.gpg] \
  https://download.docker.com/linux/ubuntu \
  $(lsb_release -cs) stable" \
  > /etc/apt/sources.list.d/docker.list

apt update
apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
apt upgrade -y
apt autoremove -y
apt clean

cat > /etc/docker/daemon.json << EOF
{
  "exec-opts": ["native.cgroupdriver=systemd"],
  "log-driver": "json-file",
  "log-opts": {
    "max-size": "100m"
  },
  "storage-driver": "overlay2",
  "storage-opts": [
    "overlay2.override_kernel_check=true"
  ]
}

EOF

containerd config default > /etc/containerd/config.toml
sed -i 's/SystemdCgroup = false/SystemdCgroup = true/g' /etc/containerd/config.toml

systemctl daemon-reload
systemctl disable docker



# ----------------------------------------
# Install Nginx
# ----------------------------------------
apt update
apt install -y nginx
apt upgrade -y
apt autoremove -y
apt clean

rm -rf /etc/nginx/conf.d
rm -rf /etc/nginx/sites-available
rm -rf /etc/nginx/sites-enabled
mkdir -pv /etc/nginx/avaiable
mkdir -pv /etc/nginx/http
mkdir -pv /etc/nginx/stream
mkdir -pv /log/nginx
mkdir -pv /code/html
chmod +x /code/html
chown -R www-data:www-data /log/nginx
chown -R www-data:www-data /code/html
chown -R www-data:www-data /etc/nginx

cat > /etc/ssl/renew.sh << EOF
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
EOF

chmod -R 744 /etc/ssl
/etc/ssl/renew.sh

cat > /etc/cron.d/renewssl << EOF
1 2 * * tue   root    /etc/ssl/renew.sh
EOF

cat > /etc/nginx/nginx.conf << EOF
user www-data;
worker_processes auto;
pid /run/nginx.pid;
include /etc/nginx/modules-enabled/*.conf;

events {
	worker_connections 768;
}

http {
	sendfile on;
	tcp_nopush on;
	types_hash_max_size 2048;
	include /etc/nginx/mime.types;
	default_type application/octet-stream;
	access_log /log/nginx/access.log;
	error_log /log/nginx/error.log;
	gzip on;
	gzip_comp_level 9;
	include /etc/nginx/http/*;
}

stream {
  include /etc/nginx/stream/*;
}

EOF


cat > /etc/nginx/avaiable/p443.conf << EOF
server {
  listen 443 http2 ssl;
  listen [::]:443 http2 ssl;
  server_name main;
  
  ssl_certificate /etc/ssl/server.crt;
  ssl_certificate_key /etc/ssl/server.key;
  ssl_dhparam /etc/ssl/dhparam.pem;

	ssl_protocols TLSv1.3;
	ssl_prefer_server_ciphers on;

  ssl_ciphers EECDH+AESGCM:EDH+AESGCM;
  ssl_ecdh_curve secp384r1;
  ssl_session_timeout  10m;
  ssl_session_cache shared:SSL:10m;

  add_header X-Frame-Options DENY;
  add_header X-Content-Type-Options nosniff;
  add_header X-XSS-Protection "1; mode=block";

  root /code/html;
  index index.html index.htm index.xhtml;

  error_page 404 /404.html;
  location = /404.html {
  }

  error_page 500 502 503 504 /50x.html;
  location = /50x.html {
  }
  
  location / {
  }
}

EOF
ln -s /etc/nginx/avaiable/p443.conf /etc/nginx/http


cat > /etc/nginx/avaiable/p80.conf << EOF
server {
  listen 80;
  listen [::]:80;
  server_name main;
  return 301 https://\$host\$request_uri;
}

EOF
ln -s /etc/nginx/avaiable/p80.conf /etc/nginx/http

cp /var/www/html/index.nginx-debian.html /code/html/index.html
rm -rf /var/www/html

nginx -t
systemctl daemon-reload
systemctl disable nginx



# ----------------------------------------
# Install FastApi
# ----------------------------------------
apt update
apt install -y python3-pip python3.10-venv
apt upgrade -y
apt autoremove -y
apt clean

mkdir -pv /code/backend
cat > /code/backend/requirements.txt << EOF
fastapi
uvicorn

EOF

cd /code/backend
python3 -m venv venv
source venv/bin/activate
pip install --upgrade -r requirements.txt
deactivate


cat > /code/backend/main.py << EOF
from fastapi import FastAPI

app = FastAPI()

@app.get('/')
async def hello():
  return 'Hello'

if __name__ == '__main__':
  from uvicorn import run
  run(app=app)

EOF

cat > /etc/systemd/system/api.service << EOF
[Unit]
Description = API Service
After=network.target

[Service]
User = root
Group = root
Type = simple
WorkingDirectory=/code/backend
Environment="PATH=/code/backend/venv/bin"
ExecStart = /code/backend/venv/bin/python3 /code/backend/main.py

[Install]
WantedBy = multi-user.target

EOF


cat > /etc/nginx/avaiable/fastapi.conf << EOF
server {
  listen 666 http2 ssl;
  listen [::]:666 http2 ssl;
  server_name fastapi;

  location / {
    include proxy_params;
    proxy_pass http://localhost:8000;
    proxy_redirect off;
  }

  ssl_certificate /etc/ssl/server.crt;
  ssl_certificate_key /etc/ssl/server.key;
  ssl_dhparam /etc/ssl/dhparam.pem;

	ssl_protocols TLSv1.3;
	ssl_prefer_server_ciphers on;

  ssl_ciphers EECDH+AESGCM:EDH+AESGCM;
  ssl_ecdh_curve secp384r1;
  ssl_session_timeout  10m;
  ssl_session_cache shared:SSL:10m;

  add_header X-Frame-Options DENY;
  add_header X-Content-Type-Options nosniff;
  add_header X-XSS-Protection "1; mode=block";

  error_page 404 /404.html;
  location = /404.html {
  }

  error_page 500 502 503 504 /50x.html;
  location = /50x.html {
  }
}

EOF
ln -s /etc/nginx/avaiable/fastapi.conf /etc/nginx/http

nginx -t
systemctl daemon-reload
