#!/bin/bash
# Setup for aiops-setup-prometheus-monitoring
set -e

# Create prometheus config directory with a minimal default config
# User needs to add the 'node' scrape job
sudo mkdir -p /etc/prometheus
cat > /etc/prometheus/prometheus.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
EOF
sudo chown -R runner:runner /etc/prometheus

echo "Ready. Edit /etc/prometheus/prometheus.yml to add a 'node' scrape job, then start the services."
echo "Use the Browser tab to access the Prometheus web UI once running."
