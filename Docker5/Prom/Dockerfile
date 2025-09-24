FROM ubuntu:24.04 AS builder

RUN apt-get update && apt-get install -y tar && rm -rf /var/lib/apt/lists/*

WORKDIR /extract
ARG PROM_VERSION=3.6.0-rc.0

ADD https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz prometheus.tar.gz

RUN tar -xzf prometheus.tar.gz \
 && rm prometheus.tar.gz

FROM ubuntu:22.04

RUN groupadd -g 1235 prom_group \
 && useradd -u 1235 -g prom_group -M -s /usr/sbin/nologin prom_user

COPY --from=builder /extract/prometheus-* /usr/local/prometheus-3.6.0-rc.0.linux-amd64

RUN mkdir -p /prometheus \
 && chown -R prom_user:prom_group /usr/local/prometheus-3.6.0-rc.0.linux-amd64 /prometheus

WORKDIR /usr/local/prometheus-3.6.0-rc.0.linux-amd64

USER prom_user
EXPOSE 9090

ENTRYPOINT ["/usr/local/prometheus-3.6.0-rc.0.linux-amd64/prometheus"]
CMD ["--config.file=/usr/local/prometheus-3.6.0-rc.0.linux-amd64/prometheus.yml"]