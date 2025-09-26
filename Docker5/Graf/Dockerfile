FROM ubuntu:24.04 AS builder

RUN apt-get update && apt-get install -y tar && rm -rf /var/lib/apt/lists/*

WORKDIR /extract
ARG GRAFANA_VERSION=12.1.1

ADD https://dl.grafana.com/oss/release/grafana-${GRAFANA_VERSION}.linux-amd64.tar.gz grafana.tar.gz

RUN tar -xzf grafana.tar.gz && rm grafana.tar.gz

FROM ubuntu:22.04

ARG GRAFANA_VERSION=12.1.1
ENV GRAFANA_HOME=/usr/local/grafana-${GRAFANA_VERSION}

RUN groupadd -g 1236 graf_group \
 && useradd -u 1236 -g graf_group -M -s /usr/sbin/nologin graf_user

COPY --from=builder /extract/grafana-${GRAFANA_VERSION} ${GRAFANA_HOME}

RUN mkdir -p ${GRAFANA_HOME}/conf/provisioning/datasources \
 && chown -R graf_user:graf_group ${GRAFANA_HOME}

WORKDIR ${GRAFANA_HOME}
USER graf_user
EXPOSE 3000

ENTRYPOINT ["/bin/sh", "-c", "exec \"$GRAFANA_HOME/bin/grafana-server\" --homepath=\"$GRAFANA_HOME\""]