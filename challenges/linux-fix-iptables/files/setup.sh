#!/bin/bash
set -e

# Set up nginx with a simple page
mkdir -p /var/www/html
cat > /var/www/html/index.html <<'HTML'
<!DOCTYPE html>
<html><body><h1>Firewall Test Page</h1></body></html>
HTML

# Start nginx
service nginx start 2>/dev/null || true

# Set restrictive iptables rules
iptables -F
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT
# Intentionally NOT allowing loopback, HTTP, or SSH
