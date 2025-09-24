FROM ubuntu:22.04

RUN apt-get update && apt-get install -y curl tar && rm -rf /var/lib/apt/lists/*

WORKDIR /usr/local
ARG GRAFANA_VERSION=12.1.1
RUN curl -fsSL -o grafana.tar.gz \
    https://dl.grafana.com/oss/release/grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz \
 && tar -xzf grafana.tar.gz \
 && rm grafana.tar.gz

RUN mkdir -p /usr/local/grafana-${GRAFANA_VERSION}/conf/provisioning/datasources

WORKDIR /usr/local/grafana-12.1.1
EXPOSE 3000

ENTRYPOINT ["/usr/local/grafana-12.1.1/bin/grafana-server"]
CMD ["--homepath=/usr/local/grafana-12.1.1"]