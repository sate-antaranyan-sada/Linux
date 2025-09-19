FROM ubuntu:24.04 AS builder

WORKDIR /extract

ADD https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz .

RUN tar -xzvf node_exporter-1.9.1.linux-amd64.tar.gz \
&& chmod +x node_exporter-1.9.1.linux-amd64/node_exporter

FROM ubuntu:22.04

RUN groupadd -g 6534 node_group \
&& useradd -u 6534 -g node_group -M -s /usr/sbin/nologin node_user

COPY --from=builder --chown=6534:6534 /extract/node_exporter-1.9.1.linux-amd64/node_exporter /usr/local/bin/

WORKDIR /node_exporter

USER node_user

EXPOSE 9100

ENTRYPOINT ["/usr/local/bin/node_exporter"]