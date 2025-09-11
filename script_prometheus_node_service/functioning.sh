#!/bin/bash
function is_active {
  svc="$1" 
  if sudo systemctl is-active --quiet "$svc"; then
    printf "There's an active "$svc". Do you want to restart it? (y/n): " 
    read ans
    if [ "$ans" == "y" ]; then
      sudo systemctl restart "$svc".service
      echo "Restarted it!"
    else
      echo "Okay, suit yourself."
    fi
  else
    printf "There's an inactive "$svc". Do you want to enable it? (y/n): " 
    read ans
    if [ "$ans" == "y" ]; then
      sudo systemctl enable "$svc".service
      sudo systemctl start "$svc".service
    else
      echo "Okay, suit yourself."
    fi
  fi
}

function add_user {
    SERVICE_NAME=$1
    sudo groupadd -f ${SERVICE_NAME}
    sudo useradd -g ${SERVICE_NAME} -M --shell /bin/false ${SERVICE_NAME}
    sudo mkdir /etc/${SERVICE_NAME}
    sudo chown ${SERVICE_NAME}:${SERVICE_NAME} /etc/${SERVICE_NAME}
}

function installing {
    path=$1
    version=$2
    SERVICE_NAME=$3
    ExecLoc=$4
    add_user ${SERVICE_NAME}
    wget ${path} -P /opt
    tar -xzvf /opt/${version}.tar.gz -C /usr/local
    sudo chown ${SERVICE_NAME}:${SERVICE_NAME} /usr/local/${version}
    cat > /etc/systemd/system/${SERVICE_NAME}.service <<EOF
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
    if [ ${SERVICE_NAME} = grafana ]; then
    cat >/usr/local/${version}/conf/provisioning/datasources/datasources.yml<<EOF
    apiVersion:1
    datasources:
        -name:Prometheus
         type: prometheus
         url: http://localhost:9090
         isdefault: true
EOF
    sudo mkdir -p /usr/local/${version}/data
    fi
    if [ ${SERVICE_NAME} = prometheus ]; then
    cat >/usr/local/${version}/${SERVICE_NAME}.yml<<EOF
    global:
        scrape_interval: 15s

    scrape_configs:
        - job_name: ${SERVICE_NAME}
          static_configs:
            - targets: ['localhost:9090']

        - job_name: node
          static_configs:
            - targets: ['localhost:9100']
EOF
    sudo mkdir -p /var/lib/${SERVICE_NAME}
    sudo chown -R ${SERVICE_NAME}:${SERVICE_NAME} /var/lib/${SERVICE_NAME}
    fi

    sudo systemctl daemon-reload
    sudo systemctl start ${SERVICE_NAME}.service
    sudo systemctl enable ${SERVICE_NAME}.service
    sudo systemctl status ${SERVICE_NAME}.service
}

node_path="https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz"
node_vers="node_exporter-1.9.1.linux-amd64"
node_Exec="/usr/local/node_exporter-1.9.1.linux-amd64/node_exporter  --web.listen-address=:9100"

if [ -e "/etc/systemd/system/node_exporter.service" ]; then
   echo "running the is_active function"
   is_active "node_exporter"
else
  printf "There is no node exporter. Do you want to install? (y/n): "
  read ans
  if [ "$ans" == "y" ]; then
  installing "${node_path}" "${node_vers}" "node_exporter" "${node_Exec}"
  else
  echo "Okay, suit yourself."
  fi
fi

prometheus_path="https://github.com/prometheus/prometheus/releases/download/v3.6.0-rc.0/prometheus-3.6.0-rc.0.linux-amd64.tar.gz"
prometheus_vers="prometheus-3.6.0-rc.0.linux-amd64"
prometheus_Exec="/usr/local/prometheus-3.6.0-rc.0.linux-amd64/prometheus --config.file=/usr/local/prometheus-3.6.0-rc.0.linux-amd64/prometheus.yml --storage.tsdb.path=/var/lib/prometheus --web.listen-address=:9090"

if [ -e "/etc/systemd/system/prometheus.service" ]; then
   echo "running the is_active function"
   is_active "prometheus"
else
  printf "There is no prometheus. Do you want to install? (y/n): "
  read ans
  if [ "$ans" == "y" ]; then
  installing "${prometheus_path}" "${prometheus_vers}" "prometheus" "${prometheus_Exec}"
  else
  echo "Okay, suit yourself."
  fi
fi
graphana_Exec="/usr/local/grafana_12.1.1_16903967602_linux_amd64 --config=/usr/local/grafana_12.1.1_16903967602_linux_amd64/conf/grafana.ini --homepath=/usr/local/grafana_12.1.1_16903967602_linux_amd64"
grafana_vers="grafana_12.1.1_16903967602_linux_amd64"

if [ -e "/etc/systemd/system/grafana.service" ]; then
   echo "running the is_active function"
   is_active "grafana"
else
  printf "There is no grafana. Do you want to install? (y/n): "
  read ans
  if [ "$ans" == "y" ]; then
  installing "${grafana_path}" "${grafana_vers}" "grafana" "${graphana_Exec}"
  else
  echo "Okay, suit yourself."
  fi
fi
