FROM ubuntu:24.04

RUN groupadd -g 6534 node_group \
&& useradd -u 6534 -g node_group -M -s /usr/sbin/nologin node_user


ADD https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz /

RUN tar -xzvf node_exporter-1.9.1.linux-amd64.tar.gz \
&& mv node_exporter-1.9.1.linux-amd64 node_exporter \
&& rm node_exporter-1.9.1.linux-amd64.tar.gz

RUN chown -R node_user:node_group /node_exporter

WORKDIR /node_exporter

USER node_user

EXPOSE 9100

ENTRYPOINT ["./node_exporter"]