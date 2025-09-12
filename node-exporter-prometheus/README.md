## Setting up Node Exporter as Using Prometheus

### 1. Installation & Running

Download the tarball from the Prometheus releases page:

```
https://prometheus.io/download/#node_exporter
```
Once downloaded extract it and run replacing the Version, OS and ARCH variables with the corresponding ones:

```bash
wget https://github.com/prometheus/node_exporter/releases/download/v<VERSION>/node_exporter-<VERSION>.<OS>-<ARCH>.tar.gz
tar xvfz node_exporter-*.*-amd64.tar.gz
cd node_exporter-*.*-amd64
./node_exporter
```

You'll see log output that confirms Node Exporter is running and listening on port 9100.

Download Prometheus from the Prometheus releases page:

```
https://prometheus.io/download/
```
Once downloaded, again, extract it and run replacing the Version, OS and ARCH variables with the corresponding ones:

```
wget https://github.com/prometheus/prometheus/releases/download/v*/prometheus-*.*-amd64.tar.gz
tar xvf prometheus-*.*-amd64.tar.gz
cd prometheus-*.*
```

### 2. Configuring Prometheus to Scrape Node Exporter

Create or update `prometheus.yml`:

```yaml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: node
    static_configs:
      - targets: ['localhost:9100']
```

Run Prometheus pointing to this config:

```bash
./prometheus --config.file=./prometheus.yml
```

### Setting up Node Exporter as a Service

### 1.  Crating a Node Exporter User

After having downloaded the Node Exporter as shown above, create a node exporter user:
```
sudo groupadd -f node_exporter
sudo useradd -g node_exporter --no-create-home --shell /bin/false node_exporter
sudo mkdir /etc/node_exporter
sudo chown node_exporter:node_exporter /etc/node_exporter
```
### 2. Move the Unpacked Node Exporter to Binary

```
mv node_exporter-1.0.1.linux-amd64 node_exporter-files
```
### 3. Install the Binary

```
# Copy the node_exporter binary into your PATH and set ownership.
sudo cp node_exporter-files/node_exporter /usr/bin/
sudo chown node_exporter:node_exporter /usr/bin/node_exporter
```
### 4. Create a systemd Service

Create the service unit file:

```
sudo vi /usr/lib/systemd/system/node_exporter.service
```

Add the following configuration

```
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
ExecStart=/usr/bin/node_exporter \
  --web.listen-address=:9200

[Install]
WantedBy=multi-user.target
```

Set appropriate permissions:
```
sudo chmod 664 /usr/lib/systemd/system/node_exporter.service
```

### 5. Reload systemd and Start Node Exporter

```
sudo systemctl daemon-reload
sudo systemctl start node_exporter
```

Check the node exporter service status using the following command:
```
sudo systemctl status node_exporter
```

Configure node_exporter to start at boot:
```
sudo systemctl enable node_exporter.service
```
If firewalld is enabled and running, add a rule for port 9200
```
sudo firewall-cmd --permanent --zone=public --add-port=9200/tcp
sudo firewall-cmd --reload
```

### Setting up Prometheus as a Service

## 1. Create a file called prometheus.service
After having downloaded Prometheus as shown above, proceed to creating the service file:
```
sudo nano /etc/systemd/system/prometheus.service
```
Add the script changing the ExecStart locations to match to the ones set above, 
or copy the files to the locations indicated below and keep the script the same

```
[Unit]
Description=Prometheus Service
After=network.target

[Service]
Type=simple
ExecStart=/usr/local/bin/prometheus/prometheus --config.file=/usr/local/bin/prometheus/prometheus.yml

[Install]
WantedBy=multi-user.target
```
### 2. Reload and Start Prometheus

```
sudo systemctl daemon-reload
sudo systemctl start prometheus
```

Check the prometheus service status using the following command:
```
sudo systemctl status prometheus
```
