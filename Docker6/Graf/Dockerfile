# Multi-stage build for Grafana using ADD
FROM ubuntu:24.04 AS builder

WORKDIR /extract

# Fetch the tarball with ADD
ADD https://dl.grafana.com/oss/release/grafana-12.1.1.linux-amd64.tar.gz .

RUN tar -xzf grafana-12.1.1.linux-amd64.tar.gz

# ----- Final image -----
FROM ubuntu:22.04

# Copy extracted Grafana directory
COPY --from=builder /extract/grafana-12.1.1 /usr/local/grafana-12.1.1

# Ensure provisioning path exists (compose will bind-mount datasources.yml here)
RUN mkdir -p /usr/local/grafana-12.1.1/conf/provisioning/datasources

WORKDIR /usr/local/grafana-12.1.1
EXPOSE 3000

ENTRYPOINT ["/usr/local/grafana-12.1.1/bin/grafana-server"]
CMD ["--homepath=/usr/local/grafana-12.1.1"]
