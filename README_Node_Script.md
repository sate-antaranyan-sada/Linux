# Node Exporter Installation Script

This repository contains a script to install Prometheus **Node Exporter** as a `systemd` service on Linux.

## Usage

### 1. Place the script
Save the script at:
```
/opt/scripts/install_node_exporter.sh
```

### 2. Make it executable
```bash
sudo chmod +x /opt/scripts/install_node_exporter.sh
```

### 3. Run it
```bash
sudo /opt/scripts/install_node_exporter.sh
```

You will be prompted to:
- Remove an existing Node Exporter installation (if found).
- Choose the version (default = `1.2.2`).

---

## Verification

Check service status:
```bash
systemctl status node_exporter 
```

Follow logs:
```bash
journalctl -u node_exporter 
```

## 📖 Documentation

For more details, see:  
👉 https://prometheus.io/docs/guides/node-exporter/
