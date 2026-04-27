#!/bin/bash
# Setup for aiops-build-grafana-dashboard
set -e

# Start node_exporter
node_exporter > /dev/null 2>&1 &

# Configure and start Prometheus
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

# Configure Grafana to serve from /browser/ subpath (for browser tab routing)
sudo sed -i 's|;root_url = .*|root_url = %(protocol)s://%(domain)s:%(http_port)s/browser/|' /etc/grafana/grafana.ini
sudo sed -i 's|;serve_from_sub_path = .*|serve_from_sub_path = true|' /etc/grafana/grafana.ini

# Start Grafana
sudo grafana-server --homepath=/usr/share/grafana --config=/etc/grafana/grafana.ini > /dev/null 2>&1 &

# Wait for Grafana to be ready
for i in $(seq 1 30); do
  if curl -sf http://localhost:3000/browser/api/health > /dev/null 2>&1; then
    break
  fi
  sleep 1
done

# Add Prometheus as a data source
curl -sf -X POST http://admin:admin@localhost:3000/browser/api/datasources \
  -H 'Content-Type: application/json' \
  -d '{"name":"Prometheus","type":"prometheus","url":"http://localhost:9090","access":"proxy","isDefault":true}' > /dev/null 2>&1 || true

echo "Ready. Prometheus, node_exporter, and Grafana are running. Use the Browser tab to access Grafana."
