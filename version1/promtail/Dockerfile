FROM ubuntu:24.04 AS builder
ARG PROMTAIL_VERSION=3.1.1
RUN apt-get update \
 && apt-get install -y --no-install-recommends curl unzip ca-certificates \
 && rm -rf /var/lib/apt/lists/*
WORKDIR /tmp

ADD https://github.com/grafana/loki/releases/download/v${PROMTAIL_VERSION}/promtail-linux-amd64.zip .
RUN unzip promtail-linux-amd64.zip -d /tmp \
 && chmod +x /tmp/promtail-linux-amd64

FROM ubuntu:22.04
RUN apt-get update \
 && apt-get install -y --no-install-recommends ca-certificates wget \
 && rm -rf /var/lib/apt/lists/*
RUN groupadd -g 6532 promtail && useradd -u 6532 -g promtail -M -s /usr/sbin/nologin promtail
RUN mkdir -p /etc/promtail /tmp && chown -R promtail:promtail /etc/promtail /tmp
COPY --from=builder /tmp/promtail-linux-amd64 /usr/local/bin/promtail
USER promtail
EXPOSE 9080
ENTRYPOINT ["/usr/local/bin/promtail"]