#!/bin/bash
set -e
# Start node_exporter and Prometheus with sample metrics
node_exporter > /dev/null 2>&1 &

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

prometheus --config.file=/etc/prometheus/prometheus.yml \
  --storage.tsdb.path=/tmp/prometheus > /dev/null 2>&1 &

sleep 5
echo "Ready. Prometheus running on :9090 with node_exporter metrics. Write your PromQL queries."
