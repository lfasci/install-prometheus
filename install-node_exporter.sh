#!/bin/bash

function display_usage {
    echo "${0} Node Exporter Version"
    exit 1	
}

if [ $# -ne 1 ]; then
    display_usage
else
    nodexporter_VERSION="$1"
fi

architecture=""
case $(uname -m) in
    i386)   architecture="386" ;;
    i686)   architecture="386" ;;
    x86_64) architecture="amd64" ;;
    arm)    dpkg --print-architecture | grep -q "arm64" && architecture="arm64" || architecture="arm" ;;
esac

CONFIGDIR="/etc/prometheus"
USER="prometheus"
wget https://github.com/prometheus/node_exporter/releases/download/v$nodexporter_VERSION/node_exporter-$nodexporter_VERSION.linux-$architecture.tar.gz
tar -xvzf node_exporter-$nodexporter_VERSION.linux-$architecture.tar.gz

# create user
if ! id -u "$username" &> /dev/null; then
	useradd --no-create-home --shell /bin/false $USER 
fi

cp node_exporter.default /etc/default/node_exporter

cd node_exporter-$nodexporter_VERSION.linux-$architecture

# copy binaries
cp -v node_exporter /usr/bin/

chown $USER:$USER  /usr/bin/node_exporter

# setup systemd
cp ../node_exporter.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable node_exporter
systemctl start node_exporter

echo "Setup complete.
Edit you settings in  $CONFIGDIR/node_exporter/node_exporter.yml:
Add the following rows in /etc/prometheus/prometheus.yml:

- job_name: node
  static_configs:
    - targets: ['localhost:9100']
restart both services: node_exporter and prometheus "

