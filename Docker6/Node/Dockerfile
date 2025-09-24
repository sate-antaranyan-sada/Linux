# Multi-stage build for Node Exporter using ADD
FROM ubuntu:24.04 AS builder

WORKDIR /extract

# Fetch the tarball with ADD
ADD https://github.com/prometheus/node_exporter/releases/download/v1.9.1/node_exporter-1.9.1.linux-amd64.tar.gz .

RUN tar -xzf node_exporter-1.9.1.linux-amd64.tar.gz

# ----- Final image -----
FROM ubuntu:22.04

# Copy just the binary into the final image
COPY --from=builder /extract/node_exporter-1.9.1.linux-amd64/node_exporter /usr/local/bin/node_exporter

EXPOSE 9100
ENTRYPOINT ["/usr/local/bin/node_exporter"]
