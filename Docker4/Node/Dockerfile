FROM ubuntu:22.04

RUN apt-get update && apt-get install -y curl tar && rm -rf /var/lib/apt/lists/*

WORKDIR /extract
ARG NODE_EXPORTER_VERSION=1.9.1
RUN curl -fsSL -o node_exporter.tar.gz \
    https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz \
 && tar -xzf node_exporter.tar.gz \
 && rm node_exporter.tar.gz

RUN mv /extract/node_exporter-*/node_exporter /usr/local/bin/node_exporter

EXPOSE 9100
ENTRYPOINT ["/usr/local/bin/node_exporter"]