FROM ubuntu:24.04 AS builder

WORKDIR /extract
ADD https://dl.grafana.com/oss/release/grafana-12.1.1.linux-amd64.tar.gz .
RUN tar -xzf grafana-12.1.1.linux-amd64.tar.gz

FROM ubuntu:24.04

RUN groupadd -g 6534 graf_group \
 && useradd -u 6534 -g graf_group -M -s /usr/sbin/nologin graf_user

COPY --from=builder --chown=6534:6534 /extract/grafana-12.1.1 /usr/local/grafana-12.1.1

COPY --chown=6534:6534 datasources.yml /usr/local/grafana-12.1.1/conf/provisioning/datasources/datasources.yml

WORKDIR /usr/local/grafana-12.1.1
USER graf_user

EXPOSE 3000

ENTRYPOINT ["/bin/grafana-server", "--homepath=/usr/local/grafana-12.1.1"]
