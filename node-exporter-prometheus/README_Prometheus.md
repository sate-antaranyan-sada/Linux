# Prometheus Installation Guide

This guide explains how to install **Prometheus v3.6.0-rc.0** on Linux, configure it, and set it up as a **systemd service**.

---

## 1. Create the installation script

Open a new file for the script:

```bash
sudo nano /opt/scripts/install_prometheus.sh
```

Paste the following content inside:

```bash
#!/bin/bash
# Prometheus Installation Script

# 1. Download Prometheus
cd /tmp
wget https://github.com/prometheus/prometheus/releases/download/v3.6.0-rc.0/prometheus-3.6.0-rc.0.linux-amd64.tar.gz

# 2. Extract archive
tar xvf prometheus-3.6.0-rc.0.linux-amd64.tar.gz

# 3. Move Prometheus to /usr/local
mv prometheus-3.6.0-rc.0.linux-amd64 /usr/local/

# 4. Create default config file
cat > /usr/local/prometheus-3.6.0-rc.0.linux-amd64/prometheus.yml << EOF
global:
  scrape_interval: 15s

scrape_configs:
- job_name: prometheus
  static_configs:
  - targets: ['localhost:9090']
EOF

# 5. Create Prometheus systemd service
cat > /usr/lib/systemd/system/prometheus.service << EOF
[Unit]
Description=Prometheus Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/prometheus-3.6.0-rc.0.linux-amd64/prometheus --config.file=/usr/local/prometheus-3.6.0-rc.0.linux-amd64/prometheus.yml
User=prometheus
Restart=on-failure

[Install]
WantedBy=multi-user.target
EOF

# 6. Create Prometheus user (no login, no home)
useradd -M -r -s /bin/false prometheus

# 7. Permissions
chown -R prometheus: /usr/local/prometheus-3.6.0-rc.0.linux-amd64/
chmod 755 /usr/local/prometheus-3.6.0-rc.0.linux-amd64/prometheus

# 8. Reload systemd and enable service
systemctl daemon-reload
systemctl enable prometheus.service
systemctl start prometheus.service
```

Save and close with `CTRL+O`, `Enter`, then `CTRL+X`.

---

## 2. Make the script executable

```bash
sudo chmod +x /opt/scripts/install_prometheus.sh
```

---

## 3. Run the script

```bash
sudo /opt/scripts/install_prometheus.sh
```

---

## 4. Verify Prometheus status

Check the service:

```bash
sudo systemctl status prometheus.service
```

---

