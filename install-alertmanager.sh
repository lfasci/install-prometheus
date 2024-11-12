#!/bin/bash
ALERTMANAGER_VERSION="0.19.0"
CONFIGDIR="/etc/prometheus"
USER="prometheus"
#wget https://github.com/prometheus/alertmanager/releases/download/v${ALERTMANAGER_VERSION}/alertmanager-${ALERTMANAGER_VERSION}.linux-armv7.tar.gz
tar -xvzf alertmanager-${ALERTMANAGER_VERSION}.linux-armv7.tar.gz
cd alertmanager-${ALERTMANAGER_VERSION}.linux-armv7

# create user
#useradd --no-create-home --shell /bin/false alertmanager 

# create directories
mkdir $CONFIGDIR/alertmanager
mkdir $CONFIGDIR/alertmanager/template
mkdir -p /var/lib/alertmanager/data

# touch config file
touch $CONFIGDIR/alertmanager/alertmanager.yml

# copy binaries
cp alertmanager /usr/local/bin/
cp amtool /usr/local/bin/

# set ownership
chown -R $USER:$USER $CONFIGDIR/alertmanager
chown -R $USER:$USER /var/lib/alertmanager
chown $USER:$USER /usr/local/bin/alertmanager
chown $USER:$USER /usr/local/bin/amtool

# setup systemd
echo "[Unit]
Description=Prometheus Alertmanager Service
Wants=network-online.target
After=network.target

[Service]
User=$USER
Group=$USER
Type=simple
ExecStart=/usr/local/bin/alertmanager \
    --config.file $CONFIGDIR/alertmanager/alertmanager.yml \
    --storage.path /var/lib/alertmanager/data
Restart=always

[Install]
WantedBy=multi-user.target" > /etc/systemd/system/alertmanager.service

systemctl daemon-reload
systemctl enable alertmanager
systemctl start alertmanager

echo "Setup complete.
Edit you settings in  $CONFIGDIR/alertmanager/alertmanager.yml:
Add the following rows in /etc/prometheus/prometheus.yml:

alerting:
  alertmanagers:
  - static_configs:
    - targets:
      - localhost:9093
restart both services: alertmanager and prometheus "

