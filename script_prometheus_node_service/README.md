# Prometheus + Node Exporter (systemd) — Install Scripts

This repository contains **two** shell scripts to install and run **Prometheus** and **Prometheus Node Exporter** as `systemd` services on Linux.

---

## Repository Layout

```
/opt/node_exporter.sh     # Script #1 — installs and configures Node Exporter (systemd)
/opt/prometheus.sh        # Script #2 — installs and configures Prometheus (systemd)
```

---

## 1 Node Exporter Install Script

**File:** `/opt/node_exporter.sh`

### What the script does
- Checks if a `node_exporter` service unit already exists and is active; if so, it **exits** without changes.
- If not present, it:
  1. Downloads **node_exporter v1.9.1** to `/opt/`.
  2. Extracts to `/usr/local/` (directory name contains version).
  3. Writes a `systemd` unit at: `/usr/lib/systemd/system/node_exporter.service`.
  4. Creates a dedicated system user `node_exporter` (no home directory, no login, no shell).
  5. Sets file ownership and permissions.
  6. Reloads `systemd`, **enables** and **starts** the service.
  7. Configures Node Exporter to listen on **`:9200`**.

### Usage
```bash
# 1) Place the script
sudo nano /opt/node_exporter.sh
#   (paste the script contents, save and exit)

# 2) Make it executable
sudo chmod +x /opt/node_exporter.sh

# 3) Run it
sudo /opt/exporter.sh
```

### Verify
```bash
# Check service
systemctl status node_exporter

# Follow logs
journalctl -u node_exporter -f

# Check metrics locally
curl -s http://localhost:9200/metrics | head
```

> **Note:** If you prefer the **default** Node Exporter port `9100`, edit the `ExecStart` line in the unit file to remove the custom `--web.listen-address=:9200` flag, then run:
> ```bash
> sudo systemctl daemon-reload
> sudo systemctl restart node_exporter
> ```

---

## 2 Prometheus Install Script

**File:** `/opt/prometheus.sh`

### What the script does
- Checks if a `prometheus` service unit exists and is active; if so, it **exits** without changes.
- If not present, it:
  1. Downloads **Prometheus v3.6.0-rc.0 (linux-amd64)**.
  2. Extracts Prometheus under `/usr/local/` (directory name contains version).
  3. Creates a minimal `prometheus.yml` that scrapes Prometheus **itself** (`localhost:9090`).
  4. Writes a `systemd` unit at `/usr/lib/systemd/system/prometheus.service`.
  5. Creates a dedicated system user **prometheus** (no login, no shell).
  6. Sets file ownership and permissions.
  7. Reloads `systemd`, **enables** and **starts** the service.

### Usage
```bash
# 1) Place the script
sudo nano /opt/prometheus.sh
#   (paste the script contents, save and exit)

# 2) Make it executable
sudo chmod +x /opt/prometheus.sh

# 3) Run it
sudo /opt/prometheus.sh
```

### Verify
```bash
# Check service
systemctl status prometheus

# Follow logs
journalctl -u prometheus
