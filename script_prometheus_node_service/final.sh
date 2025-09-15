#!/bin/bash
set -ex

# Asks the user if it wants to reconfigure returns 0, returns 1 otherwise
function ask_should_configure {
  svc="$1"
  if systemctl is-active --quiet "$svc"; then
    printf "There's an active %s. Reconfigure it? (y/n): " "$svc"
  else
    printf "There's an inactive %s. Configure it now? (y/n): " "$svc"
  fi
  read -r ans
  [[ "$ans" = "y" ]]
}

# Checks if the user exists and creates if doesn't
function check_create_user {
  SERVICE_NAME="$1"
  if getent passwd "$SERVICE_NAME" >/dev/null 2>&1; then
    echo "Found a user named ${SERVICE_NAME}"
  else
    echo "Creating a user ${SERVICE_NAME}"
    groupadd -f "$SERVICE_NAME"
    useradd -r -g "$SERVICE_NAME" -M -s /usr/sbin/nologin "$SERVICE_NAME"
    mkdir -p "/etc/${SERVICE_NAME}"
    chown "${SERVICE_NAME}:${SERVICE_NAME}" "/etc/${SERVICE_NAME}"
  fi
}

function enabling {
  SERVICE_NAME="$1"
  systemctl daemon-reload
  systemctl enable --now "${SERVICE_NAME}.service" --no-pager
  systemctl --no-pager status "${SERVICE_NAME}.service"
}

function config {
  SERVICE_NAME="$1" ExecLoc="$2"
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
  enabling "$SERVICE_NAME"
}

function installing {
  SERVICE_NAME="$1" url="$2" VERSION="$3" ExecLoc="$4"
  check_create_user "$SERVICE_NAME"
  wget -O "/opt/${VERSION}.tar.gz" "$url"
  tar -xzvf "/opt/${VERSION}.tar.gz" -C /usr/local
  chown -R "${SERVICE_NAME}:${SERVICE_NAME}" "/usr/local/${VERSION}"
  config "$SERVICE_NAME" "$ExecLoc"
}

# Return 0 only if config/installation was performed; 1 otherwise
function exists {
  SERVICE_NAME="$1" url="$2" VERSION="$3" ExecLoc="$4"

  if [ -e "/etc/systemd/system/${SERVICE_NAME}.service" ]; then
    echo "${SERVICE_NAME}.service exists."
    if ask_should_configure "$SERVICE_NAME"; then
      config "$SERVICE_NAME" "$ExecLoc"
      return 0   # did configure
    else
      echo "Skipping ${SERVICE_NAME} reconfiguration."
      return 1
    fi
  else
    printf "There is no %s. Do you want to install? (y/n): " "$SERVICE_NAME"
    read -r ans
    if [ "$ans" = "y" ]; then
      installing "$SERVICE_NAME" "$url" "$VERSION" "$ExecLoc"
      return 0  
      echo "Okay, suit yourself."
      return 1   
    fi
  fi
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

for i in node prom graf; do
  name_var="${i}_name"
  url_var="${i}_url"
  ver_var="${i}_ver"
  exec_var="${i}_exec"

  if exists "${!name_var}" "${!url_var}" "${!ver_var}" "${!exec_var}"; then
    #Comes here if the service is installed or reconfigured
    if [ "$i" == "prom" ]; then
      dir="/usr/local/${!ver_var}"
      if [ ! -d "$dir" ]; then
        echo "$dir not found. Skipping Prometheus provision"
        continue
      fi

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
      systemctl restart prometheus.service || true
      echo "Prometheus provisioning complete."

    elif [ "$i" == "graf" ]; then
      dir="/usr/local/${!ver_var}"
      if [ ! -d "$dir" ]; then
        echo "$dir not found. Skipping Grafana provision"
        continue
      fi

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
      systemctl restart grafana.service || true
      echo "Grafana provisioning complete."
    fi
  else
    echo "No changes for ${!name_var}."
  fi
done
