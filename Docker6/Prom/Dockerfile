# Multi-stage build for Prometheus using ADD
FROM ubuntu:24.04 AS builder

WORKDIR /extract

# Use ADD to fetch the tarball directly (no curl/wget needed)
ADD https://github.com/prometheus/prometheus/releases/download/v3.6.0-rc.0/prometheus-3.6.0-rc.0.linux-amd64.tar.gz .

RUN tar -xzf prometheus-3.6.0-rc.0.linux-amd64.tar.gz

# ----- Final image -----
FROM ubuntu:22.04

# Minimal base
RUN apt-get update && apt-get install -y ca-certificates && rm -rf /var/lib/apt/lists/*

# Copy extracted Prometheus from builder
COPY --from=builder /extract/prometheus-3.6.0-rc.0.linux-amd64 /usr/local/prometheus-3.6.0-rc.0.linux-amd64

# Place for query log inside container (bind-mount will overlay the file)
RUN mkdir -p /prometheus

WORKDIR /usr/local/prometheus-3.6.0-rc.0.linux-amd64
EXPOSE 9090

ENTRYPOINT ["/usr/local/prometheus-3.6.0-rc.0.linux-amd64/prometheus"]
CMD ["--config.file=/usr/local/prometheus-3.6.0-rc.0.linux-amd64/prometheus.yml"]
