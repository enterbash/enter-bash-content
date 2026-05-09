#!/bin/bash
# Setup for aiops-promql-analysis
set -e

# Configure Prometheus (runner starts services after this script)
sudo mkdir -p /etc/prometheus
cat > /etc/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 10s
scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']
EOF

# Wait for Prometheus to be started by the runner
for i in $(seq 1 30); do
  if curl -sf http://localhost:9090/api/v1/status/config > /dev/null 2>&1; then break; fi
  sleep 2
done

echo "Ready. Prometheus running on :9090 with node_exporter metrics. Write your PromQL queries."
