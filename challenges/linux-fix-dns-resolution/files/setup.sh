#!/bin/bash
set -e

# Back up original resolv.conf
sudo cp /etc/resolv.conf /etc/resolv.conf.bak 2>/dev/null || true

# Break DNS by setting invalid nameservers
sudo tee /etc/resolv.conf <<'EOF' > /dev/null
# Broken DNS configuration
nameserver 192.0.2.1
nameserver 198.51.100.1
EOF
