FROM ubuntu:24.04

RUN groupadd -g 6534 graf_group \
&& useradd -u 6534 -g graf_group -M -s /usr/sbin/nologin graf_user

WORKDIR /usr/local

ADD https://dl.grafana.com/oss/release/grafana-12.1.1.linux-amd64.tar.gz /usr/local/
RUN tar -xzf /usr/local/grafana-12.1.1.linux-amd64.tar.gz -C /usr/local/grafana-12.1.1.linux-amd64 \
&& rm grafana-12.1.1.linux-amd64.tar.gz

COPY datasources.yml /usr/local/rafana-12.1.1.linux-amd64/conf/provisioning/datasources/datasources.yml

RUN chown -R graf_user:graf_group /usr/local/grafana-12.1.1.linux-amd64

USER graf_user
WORKDIR /usr/local/grafana-12.1.1.linux-amd64

EXPOSE 3000

ENTRYPOINT ["bin/grafana-server", "--homepath=.", "--config=conf/grafana.ini"]