FROM ubuntu:24.04 AS builder

WORKDIR /extract

ADD https://github.com/prometheus/prometheus/releases/download/v3.6.0-rc.0/prometheus-3.6.0-rc.0.linux-amd64.tar.gz .

RUN tar -xzf prometheus-3.6.0-rc.0.linux-amd64.tar.gz

FROM ubuntu:22.04

RUN groupadd -g 6534 prom_group \
&& useradd -u 6534 -g prom_group -M -s /usr/sbin/nologin prom_user

COPY --from=builder --chown=6534:6534 /extract/prometheus-3.6.0-rc.0.linux-amd64 /usr/local/prometheus-3.6.0-rc.0.linux-amd64

WORKDIR /usr/local/prometheus-3.6.0-rc.0.linux-amd64

USER prom_user

EXPOSE 9090

ENTRYPOINT ["/usr/local/prometheus-3.6.0-rc.0.linux-amd64/prometheus", "--config.file=/usr/local/prometheus-3.6.0-rc.0.linux-amd64/prometheus.yml"]