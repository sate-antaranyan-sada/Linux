
# README: Automated Installation of Prometheus, Node Exporter, and Grafana

## Overview
This script automates the installation, configuration, and provisioning of:
- **Node Exporter** – for collecting Linux host metrics  
- **Prometheus** – for scraping and storing metrics  
- **Grafana** – for visualizing metrics  

It handles:
- Downloading and extracting binaries  
- Creating dedicated system users  
- Setting up systemd services  
- Provisioning default Prometheus and Grafana configurations  

---

## Prerequisites
- **Operating System**: Linux (systemd-based distribution, e.g. Ubuntu/Debian/CentOS)  
- **Dependencies**:  
  - `wget`  
  - `tar`  
  - `systemd`  
  - `bash`  
- **Privileges**: Must be run as **root** or with `sudo`  

---

## What the Script Does
1. **Checks for existing services**  
   - If the service file exists, prompts whether to restart/enable it.  
   - If not, asks whether to install it.  

2. **Creates service users**  
   - Each service gets its own user (`node_exporter`, `prometheus`, `grafana`).  
   - These users are system accounts with no login shell.  

3. **Downloads and installs binaries**  
   - Node Exporter v1.9.1  
   - Prometheus v3.6.0-rc.0  
   - Grafana v12.1.1  

   Extracted to `/usr/local/<version>/`.  

4. **Configures systemd services**  
   - Creates `/etc/systemd/system/<service>.service`  
   - Enables and starts the services  

5. **Provisions default configs**  
   - Prometheus config at:  
     `/usr/local/prometheus-<version>/prometheus.yml`  
   - Grafana datasource config at:  
     `/usr/local/grafana-<version>/conf/provisioning/datasources/datasources.yml`  

---

## Installation Steps
1. Copy the script into `/opt/scripts/install_monitoring.sh`  

   ```bash
   sudo mkdir -p /opt/scripts
   sudo nano /opt/scripts/install_monitoring.sh
   ```

   Paste the script content and save.

2. Make the script executable:

   ```bash
   sudo chmod +x /opt/scripts/install_monitoring.sh
   ```

3. Run the script:

   ```bash
   sudo /opt/scripts/install_monitoring.sh
   ```

4. Follow the prompts when asked whether to install/restart services.

---

## Installed Services
After successful execution, you will have:

- **Node Exporter**  
  - Runs on port `9100`  
  - Exposes host metrics  

- **Prometheus**  
  - Runs on port `9090`  
  - Configured to scrape itself (`localhost:9090`) and Node Exporter (`localhost:9100`)  

- **Grafana**  
  - Runs on port `3000` (default)  
  - Comes pre-provisioned with Prometheus as a datasource  

---

## Verifying Installations
- Check services:

  ```bash
  systemctl status node_exporter
  systemctl status prometheus
  systemctl status grafana
  ```

- Test in browser:
  - Prometheus → http://localhost:9090  
  - Node Exporter → http://localhost:9100/metrics  
  - Grafana → http://localhost:3000 (default credentials: `admin` / `admin`)  

---

## File Locations
- **Systemd services** → `/etc/systemd/system/`  
- **Prometheus binary/config** → `/usr/local/prometheus-<version>/`  
- **Grafana binary/config** → `/usr/local/grafana-<version>/`  
- **Node Exporter binary** → `/usr/local/node_exporter-<version>/`  
- **Prometheus data directory** → `/var/lib/prometheus`  

---

## Notes
- Versions are pinned inside the script. Update URLs and version variables if you want newer releases.  
- Script uses interactive prompts (`y/n`) — automation will require modifying/removing those.  
- Run on a clean system to avoid conflicts with preinstalled Prometheus/Grafana services.  
