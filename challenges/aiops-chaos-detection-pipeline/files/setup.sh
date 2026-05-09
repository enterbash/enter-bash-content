#!/bin/bash
# Setup for aiops-chaos-detection-pipeline
set -e

# Configure Prometheus (runner starts services after this script)
sudo mkdir -p /etc/prometheus
cat > /etc/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 5s
scrape_configs:
  - job_name: 'node'
    static_configs:
      - targets: ['localhost:9100']
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
EOF

# Wait for services to be started by the runner
for i in $(seq 1 30); do
  if curl -sf http://localhost:3000/api/health > /dev/null 2>&1; then break; fi
  sleep 2
done

# Add Prometheus datasource to Grafana
curl -sf -X POST http://admin:admin@localhost:3000/api/datasources \
  -H 'Content-Type: application/json' \
  -d '{"name":"Prometheus","type":"prometheus","url":"http://localhost:9090","access":"proxy","isDefault":true}' > /dev/null 2>&1 || true

# Create chaos injection script
cat > ~/inject_chaos.sh << 'CHAOS'
#!/bin/bash
echo "Injecting CPU and memory stress for 30 seconds..."
stress-ng --cpu 2 --vm 1 --vm-bytes 256M --timeout 30s --metrics-brief 2>&1
echo "Chaos injection complete."
CHAOS
chmod +x ~/inject_chaos.sh

echo "Ready: Prometheus (:9090), node_exporter (:9100), Grafana (:3000) running."
echo "Use ~/inject_chaos.sh to inject chaos, then build your detection pipeline."
