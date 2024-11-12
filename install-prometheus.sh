#!/bin/bash

function display_usage {
    echo "${0} Prometheus Version"
    exit 1	
}


if [ $# -ne 1 ]; then
    display_usage
else
    prometheus_VERSION="$1"
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
# wget https://github.com/prometheus/prometheus/releases/download/v${prometheus_VERSION}/prometheus-${prometheus_VERSION}.linux-$architecture.tar.gz
# tar -xvzf prometheus-${prometheus_VERSION}.linux-$architecture.tar.gz
cd prometheus-${prometheus_VERSION}.linux-$architecture

# create user
if ! id -u "$username" &> /dev/null; then
	useradd --no-create-home --shell /bin/false $USER 
fi

# create directories
mkdir -p $CONFIGDIR
mkdir -p /var/lib/prometheus/data

# Copy config file
cp prometheus.yml $CONFIGDIR
cp ../prometheus.default /etc/default/prometheus

# setup systemd
cp ../prometheus.service /etc/systemd/system/
systemctl daemon-reload
systemctl enable prometheus

# copy binaries
cp prometheus /usr/bin/
cp promtool /usr/bin/

#Copy console files
cp -r consoles /etc/prometheus/
cp -r console_libraries /etc/prometheus/

# set ownership
chown -R $USER:$USER $CONFIGDIR
chown -R $USER:$USER /var/lib/prometheus
chown $USER:$USER /usr/bin/prometheus
chown $USER:$USER /usr/bin/promtool

echo "Setup complete.
Edit you settings in  $CONFIGDIR/prometheus/prometheus.yml"

