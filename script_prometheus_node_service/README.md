
# Automated Installation of Prometheus, Node Exporter, and Grafana

## Overview
This script automates the installation and configuration of Node Exporter, Prometheus and Grafana

It handles:
- Downloading and extracting binaries  
- Creating dedicated system users  
- Setting up systemd services  
- Provisioning default Prometheus and Grafana configurations  

---

## What the Script Does
1. **Checks for existing services**  
   - If the service file exists, checks if it's active and promts to reconfigurate or not.  
   - If not, asks whether to install it.  

2. **Checks for existing users** 
   - Checks if service users exists and creates if they don't
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

5. **Default configs for prometheus and grafana**  
   - Prometheus config at:  
     `/usr/local/prometheus-<version>/prometheus.yml`  
   - Grafana datasource config at:  
     `/usr/local/grafana-<version>/conf/provisioning/datasources/datasources.yml`  

---

## Installation Steps
1. Clone the git repo 

2. Find the script_prometheus_node_service folder and the final.sh file

2. Make the script executable:

   ```bash
   chmod +x final.sh
   ```

3. Run the script as a root user as it checks /etc/passwd:

   ```bash
   sudo ./final.sh
   ```

4. Follow the prompts when asked whether to install/reconfigure the services.

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

## File Locations
- **Systemd services** → `/etc/systemd/system/`  
- **Prometheus binary/config** → `/usr/local/prometheus-<version>/`  
- **Grafana binary/config** → `/usr/local/grafana-<version>/`  
- **Node Exporter binary** → `/usr/local/node_exporter-<version>/`  
- **Prometheus data directory** → `/var/lib/prometheus`  

---

## Notes
- You can chnage the versions being downloaded when calling the functions.
