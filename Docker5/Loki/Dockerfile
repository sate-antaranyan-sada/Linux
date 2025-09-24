FROM ubuntu:24.04

ADD https://github.com/grafana/loki/releases/download/v3.5.5/loki-linux-amd64.zip
RUN unzip loki-linux-amd64.zip \
&& mv loki-linux-amd64 /usr/local/bin/loki


ENTRYPOINT["/usr/local/bin/loki/loki-linux-amd64"]
CMD["-config.file=loki-local-config.yaml"]