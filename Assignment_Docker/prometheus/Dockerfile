FROM ubuntu:24.04

RUN groupadd -g 6534 prom_group \
&& useradd -u 6534 -g prom_group -M -s /usr/sbin/nologin prom_user

WORKDIR /usr/local

ADD https://github.com/prometheus/prometheus/releases/download/v3.6.0-rc.0/prometheus-3.6.0-rc.0.linux-amd64.tar.gz /usr/local

RUN tar -xzf prometheus-3.6.0-rc.0.linux-amd64.tar.gz \
&& rm prometheus-3.6.0-rc.0.linux-amd64.tar.gz

COPY prometheus.yml /usr/local/prometheus-3.6.0-rc.0.linux-amd64

RUN chown -R prom_user:prom_group /usr/local/prometheus-3.6.0-rc.0.linux-amd64

WORKDIR /usr/local/prometheus-3.6.0-rc.0.linux-amd64

USER prom_user

EXPOSE 9090

ENTRYPOINT ["./prometheus", "--config.file=./prometheus.yml"]