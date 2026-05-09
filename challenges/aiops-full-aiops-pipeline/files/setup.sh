#!/bin/bash
# Setup for aiops-full-aiops-pipeline
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

# Start mock LLM server (this is a user-space service, not a system service)
nohup python3 ~/mock_llm_server.py > /dev/null 2>&1 &
disown

echo "Ready: Full AIOps pipeline environment."
echo "  - Prometheus: http://localhost:9090"
echo "  - Node Exporter: http://localhost:9100"
echo "  - Grafana: http://localhost:3000"
echo "  - Mock LLM: http://localhost:8080"
echo "  - Failure injector: python3 ~/inject_failure.py"
