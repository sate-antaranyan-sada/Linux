FROM ubuntu:24.04 AS builder

ARG LOKI_VERSION=3.1.1
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl unzip ca-certificates \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /tmp

ADD https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/loki-linux-amd64.zip .
ADD https://github.com/grafana/loki/releases/download/v${LOKI_VERSION}/SHA256SUMS .
RUN grep "loki-linux-amd64.zip" SHA256SUMS | sha256sum -c - \
 && unzip loki-linux-amd64.zip -d /tmp \
 && chmod +x /tmp/loki-linux-amd64

FROM ubuntu:22.04

RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates \
 && rm -rf /var/lib/apt/lists/*
RUN groupadd -g 6531 loki && useradd -u 6531 -g loki -M -s /usr/sbin/nologin loki
RUN mkdir -p /etc/loki /loki && chown -R loki:loki /etc/loki /loki
COPY --from=builder /tmp/loki-linux-amd64 /usr/local/bin/loki
USER loki
EXPOSE 3100
# Simple health—Loki exposes /ready once config is valid
HEALTHCHECK --interval=30s --timeout=3s --retries=5 CMD wget -qO- http://127.0.0.1:3100/ready || exit 1

ENTRYPOINT ["/usr/local/bin/loki"]