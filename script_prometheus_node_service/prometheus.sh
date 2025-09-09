#!/bin/bash
SERVICE_NAME2="prometheus"

if [ -e "/usr/lib/systemd/system/${SERVICE_NAME2}.service" ]; then
    echo "There's an active $SERVICE_NAME2."
    exit 0
else
    echo "No $SERVICE_NAME2 service file found."

    wget https://github.com/prometheus/prometheus/releases/download/v3.6.0-rc.0/prometheus-3.6.0-rc.0.linux-amd64.tar.gz
    tar -xvf prometheus-3.6.0-rc.0.linux-amd64.tar.gz
    mv prometheus-3.6.0-rc.0.linux-amd64 /usr/local

    cat >/usr/local/prometheus-3.6.0-rc.0.linux-amd64/prometheus.yml<< EOF
    global:
    scrape_interval: 15s

    scrape_configs:
    - job_name: prometheus
        static_configs:
        - targets: ['localhost:9090']
EOF
    sudo mkdir -p /var/lib/premetheus #Data directory

    cat >/usr/lib/systemd/system/prometheus.service<< EOF
    [Unit]
    Description=Prometheus Service
    After=network.target

    [Service]
    Type=simple 
    ExecStart=/usr/local/prometheus-3.6.0-rc.0.linux-amd64/prometheus \
        --config.file=/usr/local/prometheus-3.6.0-rc.0.linux-amd64/prometheus.yml \
        --storage.tsdb.path=/var/lib/prometheus \
        --web.listen-address=:9090
    Restart=on-failure
    RestartSec=2

    [Install]
    WantedBy=multi-user.target
EOF
    sudo useradd -r -s /usr/sbin/nologin prometheus
    sudo chown -R prometheus:prometheus /usr/local/prometheus-3.6.0-rc.0.linux-amd64/prometheus
    sudo chown -R prometheus:prometheus /usr/local/prometheus-3.6.0-rc.0.linux-amd64 /var/lib/prometheus
    sudo chmod 755 /usr/local/prometheus-3.6.0-rc.0.linux-amd64/prometheus
    sudo systemctl daemon-reload
    sudo systemctl start prometheus.service
    sudo systemctl enable prometheus.service
    sudo systemctl status prometheus.service
fi
