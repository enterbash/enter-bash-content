#!/bin/bash
set -e

# Start Prometheus
cat > /tmp/prometheus.yml << 'EOF'
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

prometheus --config.file=/tmp/prometheus.yml --storage.tsdb.path=/tmp/prometheus-data --web.listen-address=:9090 &
sleep 2

# Start node_exporter
node_exporter --web.listen-address=:9100 &
sleep 1

# Start Grafana
grafana-server --homepath=/usr/share/grafana --config=/etc/grafana/grafana.ini web &
sleep 2

# Start mock LLM server
python3 ~/mock_llm_server.py &
sleep 1

echo "Ready: Full AIOps pipeline environment."
echo "  - Prometheus: http://localhost:9090"
echo "  - Node Exporter: http://localhost:9100"
echo "  - Grafana: http://localhost:3000"
echo "  - Mock LLM: http://localhost:8080"
echo "  - Failure injector: python3 ~/inject_failure.py"
