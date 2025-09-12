#!/bin/bash
set -ex

function exists {
  SERVICE_NAME="$1" url="$2" VERSION="$3" ExecLoc="$4"
  if [ -e "/etc/systemd/system/${SERVICE_NAME}.service" ]; then
    echo "${SERVICE_NAME}.service exists; checking if it's active."
    is_active "${SERVICE_NAME}"
  else
    printf "There is no %s. Do you want to install? (y/n): " "$SERVICE_NAME"
    read -r ans
    if [ "$ans" = "y" ]; then
      installing "$SERVICE_NAME" "$url" "$VERSION" "$ExecLoc"
    else
      echo "Okay, suit yourself."
    fi
  fi
}

function is_active {
  svc="$1"
  if systemctl is-active --quiet "$svc"; then
    printf "There's an active %s. Do you want to restart it? (y/n): " "$svc"
    read -r ans
    if [ "$ans" = "y" ]; then
      systemctl restart "${svc}.service"
      echo "Restarted it!"
    else
      echo "Okay, suit yourself."
    fi
  else
    printf "There's an inactive %s. Do you want to enable it? (y/n): " "$svc"
    read -r ans
    if [ "$ans" = "y" ]; then
      systemctl enable "${svc}.service"
      systemctl start  "${svc}.service"
    else
      echo "Okay, suit yourself."
    fi
  fi
}

function check_create_user {
  SERVICE_NAME="$1"
  if getent passwd "$SERVICE_NAME" >/dev/null 2>&1; then
    echo "Found a user named ${SERVICE_NAME}"
  else
    echo "Creating a user ${SERVICE_NAME}"
    sudo groupadd -f "$SERVICE_NAME"
    sudo useradd -r -g "$SERVICE_NAME" -M -s /usr/sbin/nologin "$SERVICE_NAME"
    sudo mkdir -p "/etc/${SERVICE_NAME}"
    chown "${SERVICE_NAME}:${SERVICE_NAME}" "/etc/${SERVICE_NAME}"
  fi
}

function installing {
  SERVICE_NAME="$1" url="$2" VERSION="$3" ExecLoc="$4"

  check_create_user "$SERVICE_NAME"

  wget -O "/opt/${VERSION}.tar.gz" "$url"
  tar -xzvf "/opt/${VERSION}.tar.gz" -C /usr/local
  chown -R "${SERVICE_NAME}:${SERVICE_NAME}" "/usr/local/${VERSION}"
  tee "/etc/systemd/system/${SERVICE_NAME}.service" >/dev/null <<EOF
[Unit]
Wants=network-online.target
After=network-online.target

[Service]
User=${SERVICE_NAME}
Group=${SERVICE_NAME}
Type=simple
Restart=on-failure
ExecStart=${ExecLoc}

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable "${SERVICE_NAME}.service"
  systemctl start  "${SERVICE_NAME}.service"
  systemctl status "${SERVICE_NAME}.service" --no-pager || true
}

function provision_prometheus {
  VERSION="$1" dir="/usr/local/${VERSION}"
  [ -d "$dir" ] || { echo "$dir not found. Skipping provision"; return 0; }

  tee "${dir}/prometheus.yml" >/dev/null <<'EOF'
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: prometheus
    static_configs:
      - targets: ['localhost:9090']

  - job_name: node
    static_configs:
      - targets: ['localhost:9100']
EOF

  mkdir -p /var/lib/prometheus
  chown -R prometheus:prometheus /var/lib/prometheus
  echo "Prometheus provisioning complete."
}

function provision_grafana {
  VERSION="$1" dir="/usr/local/${VERSION}"
  [ -d "$dir" ] || { echo "$dir not found. Skipping provision"; return 0; }

  mkdir -p "${dir}/conf/provisioning/datasources" "${dir}/data" "${dir}/logs"

  tee "${dir}/conf/provisioning/datasources/datasources.yml" >/dev/null <<'EOF'
apiVersion: 1
datasources:
  - name: Prometheus
    type: prometheus
    url: http://localhost:9090
    isDefault: true
EOF

  chown -R grafana:grafana "${dir}/conf" "${dir}/data" "${dir}/logs"
  echo "Grafana provisioning complete."
}

node_name="node_exporter"
node_url="https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz"
node_ver="node_exporter-1.9.1.linux-amd64"
node_exec="/usr/local/${node_ver}/node_exporter --web.listen-address=:9100"

prom_name="prometheus"
prom_url="https://github.com/prometheus/prometheus/releases/download/v3.6.0-rc.0/prometheus-3.6.0-rc.0.linux-amd64.tar.gz"
prom_ver="prometheus-3.6.0-rc.0.linux-amd64"
prom_exec="/usr/local/${prom_ver}/prometheus --config.file=/usr/local/${prom_ver}/prometheus.yml --storage.tsdb.path=/var/lib/prometheus --web.listen-address=:9090"

graf_name="grafana"
graf_url="https://dl.grafana.com/oss/release/grafana-12.1.1.linux-amd64.tar.gz"
graf_ver="grafana-12.1.1"
graf_exec="/usr/local/${graf_ver}/bin/grafana-server --homepath=/usr/local/${graf_ver}"

NAME="$node_name"; URL="$node_url"; VERSION="$node_ver"; EXEC="$node_exec"
exists "$NAME" "$URL" "$VERSION" "$EXEC"

NAME="$prom_name"; URL="$prom_url"; VERSION="$prom_ver"; EXEC="$prom_exec"
exists "$NAME" "$URL" "$VERSION" "$EXEC"
provision_prometheus "$VERSION"

NAME="$graf_name"; URL="$graf_url"; VERSION="$graf_ver"; EXEC="$graf_exec"
exists "$NAME" "$URL" "$VERSION" "$EXEC"
provision_grafana "$VERSION"