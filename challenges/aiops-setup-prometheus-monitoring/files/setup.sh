#!/bin/bash
# Setup for aiops-setup-prometheus-monitoring
set -e

# Create prometheus config directory
sudo mkdir -p /etc/prometheus

# Create a minimal default config (user needs to add the node scrape job)
cat > /tmp/prometheus-default.yml << 'EOF'
global:
  scrape_interval: 15s
  evaluation_interval: 15s

scrape_configs:
  - job_name: 'prometheus'
    static_configs:
      - targets: ['localhost:9090']
EOF

sudo cp /tmp/prometheus-default.yml /etc/prometheus/prometheus.yml
sudo chown -R runner:runner /etc/prometheus

echo "NOTE: When starting Prometheus, use: prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/tmp/prometheus --web.external-url=/browser/ --web.route-prefix=/ &"
