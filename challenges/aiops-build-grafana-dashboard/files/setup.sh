#!/bin/bash
# Setup for aiops-build-grafana-dashboard
set -e

# Configure Prometheus (runner starts the services after this script)
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

# Wait for services to be started by the runner
for i in $(seq 1 30); do
  if curl -sf http://localhost:3000/api/health > /dev/null 2>&1; then break; fi
  sleep 2
done

# Add Prometheus as a data source
curl -sf -X POST http://admin:admin@localhost:3000/api/datasources \
  -H 'Content-Type: application/json' \
  -d '{"name":"Prometheus","type":"prometheus","url":"http://localhost:9090","access":"proxy","isDefault":true}' > /dev/null 2>&1 || true

echo "Ready. Prometheus, node_exporter, and Grafana are running. Use the Browser tab to access Grafana."
