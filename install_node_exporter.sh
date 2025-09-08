echo_yellow() { printf "\e[93m%s\e[0m\n" "$*"; }

SERVICE_NAME="node_exporter"
UNIT_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

if [ -e "$UNIT_FILE" ]; then
    if sudo systemctl is-active --quiet "$SERVICE_NAME"; then
        echo_yellow "There's an active $SERVICE_NAME."
        NODE_EXPORTER_PATH="/usr/local/${SERVICE_NAME}/${SERVICE_NAME}"
        if [ -x "$NODE_EXPORTER_PATH" ]; then
            VERSION_INFO="$("$NODE_EXPORTER_PATH" --version 2>/dev/null | awk '/node_exporter/ {print $3; exit}')"
            echo_yellow "Active Node Exporter Version: ${VERSION_INFO:-unknown}"
        else
            echo_yellow "node_exporter binary not found at $NODE_EXPORTER_PATH"
        fi
        echo
        echo_yellow "Removing all node_exporter files..."
        echo
        sudo systemctl stop "$SERVICE_NAME" || true
        sudo systemctl disable "$SERVICE_NAME" || true
        sudo rm -f "$UNIT_FILE"
        sudo rm -rf /usr/local/node_exporter*
        sudo systemctl daemon-reload
        echo
        echo "Related files removed."
        echo
        echo "Installation will continue..."
        echo
    else
        echo "There's a $SERVICE_NAME service that is not active. Removing related files..."
        sudo systemctl stop "$SERVICE_NAME" || true
        sudo systemctl disable "$SERVICE_NAME" || true
        sudo rm -f "$UNIT_FILE"
        sudo rm -rf /usr/local/node_exporter*
        sudo systemctl daemon-reload
        echo
        echo "Related files removed."
        echo
        echo "Installation will continue..."
        echo
    fi
else
    echo "No $SERVICE_NAME service file found."
    echo
fi
echo_yellow -n "Insert the version you would lilke to be installed, default is [ 1.9.1 ] :"
read VERSION
VERSION=${VERSION:-1.9.1}
echo
wget https://github.com/prometheus/node_exporter/releases/download/v$VERSION/node_exporter-$VERSION.linux-amd64.tar.gz -P /opt
tar -xzvf /opt/node_exporter-$VERSION.linux-amd64.tar.gz -C /usr/local && mv /usr/local/node_exporter-$VERSION.linux-amd64 /usr/local_node_exporter
cat >>/usr/lib/systemd/system/node_exporter.service<< EOF
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
ExecStart=/usr/local/node_exporter-*/node_exporter  --web.listen-address=:9200
"/opt/scripts/install_node_exporter.sh" [readonly] 76L, 2799B                                                                                                                                                                               1,1           Top
echo_yellow() { printf "\e[93m%s\e[0m\n" "$*"; }

SERVICE_NAME="node_exporter"
UNIT_FILE="/etc/systemd/system/${SERVICE_NAME}.service"

if [ -e "$UNIT_FILE" ]; then
    if sudo systemctl is-active --quiet "$SERVICE_NAME"; then
        echo_yellow "There's an active $SERVICE_NAME."
        NODE_EXPORTER_PATH="/usr/local/${SERVICE_NAME}/${SERVICE_NAME}"
        if [ -x "$NODE_EXPORTER_PATH" ]; then
            VERSION_INFO="$("$NODE_EXPORTER_PATH" --version 2>/dev/null | awk '/node_exporter/ {print $3; exit}')"
            echo_yellow "Active Node Exporter Version: ${VERSION_INFO:-unknown}"
        else
            echo_yellow "node_exporter binary not found at $NODE_EXPORTER_PATH"
        fi
        echo
        echo_yellow "Removing all node_exporter files..."
        echo
        sudo systemctl stop "$SERVICE_NAME" || true
        sudo systemctl disable "$SERVICE_NAME" || true
        sudo rm -f "$UNIT_FILE"
        sudo rm -rf /usr/local/node_exporter*
        sudo systemctl daemon-reload
        echo
        echo "Related files removed."
        echo
        echo "Installation will continue..."
        echo
    else
        echo "There's a $SERVICE_NAME service that is not active. Removing related files..."
        sudo systemctl stop "$SERVICE_NAME" || true
        sudo systemctl disable "$SERVICE_NAME" || true
        sudo rm -f "$UNIT_FILE"
        sudo rm -rf /usr/local/node_exporter*
        sudo systemctl daemon-reload
        echo
        echo "Related files removed."
        echo
        echo "Installation will continue..."
        echo
    fi
else
    echo "No $SERVICE_NAME service file found."
    echo
fi
echo_yellow -n "Insert the version you would lilke to be installed, default is [ 1.9.1 ] :"
read VERSION
VERSION=${VERSION:-1.9.1}
echo
wget https://github.com/prometheus/node_exporter/releases/download/v$VERSION/node_exporter-$VERSION.linux-amd64.tar.gz -P /opt
tar -xzvf /opt/node_exporter-$VERSION.linux-amd64.tar.gz -C /usr/local && mv /usr/local/node_exporter-$VERSION.linux-amd64 /usr/local_node_exporter
cat >>/usr/lib/systemd/system/node_exporter.service<< EOF
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
ExecStart=/usr/local/node_exporter-*/node_exporter  --web.listen-address=:9200

[Install]
WantedBy=multi-user.target
EOF

sudo useradd -M -r -s /bin/false node_exporter
sudo chown -R node_exporter. /usr/local/node_exporter/node_exporter
sudo chmod 755 /usr/local/node_exporter/node_exporter
sudo systemctl daemon-reload
sudo systemctl start node_exporter.service
sudo systemctl enable node_exporter.service
sudo systemctl status node_exporter.service
