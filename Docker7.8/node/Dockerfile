FROM ubuntu:22.04 AS builder
RUN apt-get update && apt-get install -y curl tar && rm -rf /var/lib/apt/lists/*
WORKDIR /extract
ARG NODE_EXPORTER_VERSION=1.9.1
RUN curl -fsSL -o node_exporter.tar.gz \
    https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz \
 && tar -xzf node_exporter.tar.gz \
 && rm node_exporter.tar.gz

RUN mv /extract/node_exporter-*/node_exporter /usr/local/bin/node_exporter

FROM ubuntu:22.04
RUN groupadd -g 6535 node_group && useradd -u 6535 -g node_group -M -s /usr/sbin/nologin node_user

COPY --from=builder /usr/local/bin/node_exporter /usr/local/bin/node_exporter
RUN chown node_user:node_group /usr/local/bin/node_exporter

USER node_user
EXPOSE 9100
ENTRYPOINT ["/usr/local/bin/node_exporter"]