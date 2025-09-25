FROM ubuntu:22.04 AS builder
ARG GRAFANA_VERSION=12.1.1
RUN apt-get update && apt-get install -y curl tar ca-certificates && rm -rf /var/lib/apt/lists/*
WORKDIR /usr/local
ADD https://dl.grafana.com/oss/release/grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz /usr/local/grafana.tar.gz
RUN tar -xzf grafana.tar.gz && rm grafana.tar.gz \
 && mv grafana-${GRAFANA_VERSION} grafana \
 && mkdir -p /etc/grafana/provisioning/datasources

FROM ubuntu:22.04
RUN groupadd -g 6533 grafana && useradd -u 6533 -g grafana -M -s /usr/sbin/nologin grafana
COPY --from=builder /usr/local/grafana /usr/local/grafana
COPY --from=builder /etc/grafana /etc/grafana
RUN chown -R grafana:grafana /usr/local/grafana /etc/grafana

USER grafana
WORKDIR /usr/local/grafana
EXPOSE 3000
ENTRYPOINT ["/usr/local/grafana/bin/grafana-server"]
CMD ["--homepath=/usr/local/grafana"]