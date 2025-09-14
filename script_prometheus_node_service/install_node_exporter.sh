SERVICE_NAME="node_exporter"
UNIT_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

if [ -e "$UNIT_FILE" ]; then
    if sudo systemctl is-active --quiet "$SERVICE_NAME"; then
        echo "There's an active $SERVICE_NAME."
        exit 0
    fi
else
    echo "No $SERVICE_NAME service file found."
    wget https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz -P /opt
    tar -xzvf /opt/node_exporter-1.9.1.linux-amd64.tar.gz -C /usr/local && mv /usr/local/node_exporter-1.9.1.linux-amd64 /usr/local_node_exporter
    cat > /usr/lib/systemd/system/node_exporter.service << EOF
    [Unit]
    Description=Node Exporter
    Documentation=https://prometheus.io/docs/guides/node-exporter/
    Wants=network-online.target
    After=network-online.target

    [Service]
    User=node_exporter
    Group=node_exporter
    Type=simple
    Restart=on-failure
    ExecStart=/usr/local/node_exporter-1.9.1.linux-amd64/node_exporter  --web.listen-address=:9200

    [Install]
    WantedBy=multi-user.target
EOF

    sudo useradd -M -r /bin/false node_exporter
    sudo chown -R node_exporter. /usr/local/node_exporter-1.9.1.linux-amd64/node_exporter
    sudo chmod 755 /usr/local/node_exporter-1.9.1.linux-amd64/node_exporter
    sudo systemctl daemon-reload
    sudo systemctl start node_exporter.service
    sudo systemctl enable node_exporter.service
    sudo systemctl status node_exporter.service
fi

SERVICE_NAME2="prometheus"
UNIT_FILE2="/etc/systemd/system/${SERVICE_NAME2}.service"

if [ -e "$UNIT_FILE2" ]; then
    if sudo systemctl is-active --quiet "$SERVICE_NAME2"; then
        echo "There's an active $SERVICE_NAME2."
        exit 0
    fi
else
    echo "No $SERVICE_NAME2 service file found."

    wget https://github.com/prometheus/prometheus/releases/download/v3.6.0-rc.0/prometheus-3.6.0-rc.0.linux-amd64.tar.gz
    tar xvf prometheus-3.6.0-rc.0.linux-amd64.tar.gz
    mv /usr/local/prometheus-3.6.0-rc.0.linux-amd64 /usr/local_prometheus

    cat >/usr/local/prometheus-3.6.0-rc.0.linux-amd64/prometheus.yml<< EOF
    global:
    scrape_interval: 15s
    scrape_configs:
    - job_name: prometheus
    static_configs:
    - targets: ['localhost:9090']
EOF

    cat >/usr/lib/systemd/system/prometheus.service<< EOF
    [Unit]
    Description=Prometheus Service
    After=network.target

    [Service]
    Type=simple
    ExecStart=/usr/local/prometheus-3.6.0-rc.0.linux-amd64/prometheus --config.file=/usr/local/prometheus-3.6.0-rc.0.linux-amd64/prometheus.yml

    [Install]
    WantedBy=multi-user.target
EOF

    sudo useradd -M -r /bin/false prometheus
    sudo chown -R prometheus. /usr/local/prometheus-3.6.0-rc.0.linux-amd64/prometheus
    sudo chmod 755 /usr/local/prometheus-3.6.0-rc.0.linux-amd64/prometheus
    sudo systemctl daemon-reload
    sudo systemctl start prometheus.service
    sudo systemctl enable prometheus.service
    sudo systemctl status prometheus.service