#!/usr/bin/env bash
function is_active {
  svc="$1" #service name
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

if [ -e "/etc/systemd/system/node_exporter.service" ]; then #checks if the node_exporter.service exists
  is_active node_exporter
else #if it doesn't
  installing path version SERVICE_NAME ExecLoc
fi


sudo apt-get install -y apt-transport-https software-properties-common
sudo mkdir -p /etc/apt/keyrings/
wget -q -O - https://apt.grafana.com/gpg.key | gpg --dearmor | sudo tee /etc/apt/keyrings/grafana.gpg > /dev/null
echo "deb [signed-by=/etc/apt/keyrings/grafana.gpg] https://apt.grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
apt-get update 
apt-get install -y adduser libfontconfig1 musl
wget https://dl.grafana.com/oss/release/grafana_${GRAFANA_VERSION}_amd64.deb
sudo dpkg -i grafana_${GRAFANA_VERSION}_amd64. deb
echo "export PATH=/usr/share/grafana/bin:$PATH" >> /etc/profile

cat >/etc/grafana/provisioning/datasources/prometheus.yaml<<EOF
apiVersion: 1

datasources:
    - name: Prometheus 
      type: prometheus url:
      url: ${PROMETHEUS_URL}
EOF
systemctl daemon-reload
systemctl enable grafana-server
systemctl start grafana-server
systemctl status grafana-server