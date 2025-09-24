FROM ubuntu:22.04

RUN apt-get update && apt-get install -y curl tar && rm -rf /var/lib/apt/lists/*

WORKDIR /extract
ARG PROM_VERSION=3.6.0-rc.0
RUN curl -fsSL -o prometheus.tar.gz \
    https://github.com/prometheus/prometheus/releases/download/v${PROM_VERSION}/prometheus-${PROM_VERSION}.linux-amd64.tar.gz \
 && tar -xzf prometheus.tar.gz \
 && rm prometheus.tar.gz

RUN mv /extract/prometheus-* /usr/local/prometheus-3.6.0-rc.0.linux-amd64
RUN mkdir -p /prometheus

WORKDIR /usr/local/prometheus-3.6.0-rc.0.linux-amd64
EXPOSE 9090

ENTRYPOINT ["/usr/local/prometheus-3.6.0-rc.0.linux-amd64/prometheus"]
CMD ["--config.file=/usr/local/prometheus-3.6.0-rc.0.linux-amd64/prometheus.yml"]