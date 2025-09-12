SERVICE_NAME="node_exporter"

if [ -e "usr/lib/systemd/system/${SERVICE_NAME}.service" ]; then
    echo "There's a $SERVICE_NAME installed."
    exit 0

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