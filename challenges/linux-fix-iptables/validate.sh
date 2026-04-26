#!/bin/bash
set -e

# Check loopback is allowed
if ! sudo iptables -L INPUT -n | grep -q 'lo.*ACCEPT\|ACCEPT.*lo'; then
  # Check with -v for interface
  if ! sudo iptables -L INPUT -n -v | grep -q 'lo.*ACCEPT'; then
    echo "FAIL: Loopback traffic is not allowed"
    exit 1
  fi
fi

# Check port 80 is allowed
if ! sudo iptables -L INPUT -n | grep -qE 'tcp dpt:80.*ACCEPT|ACCEPT.*tcp.*80'; then
  echo "FAIL: HTTP (port 80) is not allowed"
  exit 1
fi

# Check port 22 is allowed
if ! sudo iptables -L INPUT -n | grep -qE 'tcp dpt:22.*ACCEPT|ACCEPT.*tcp.*22'; then
  echo "FAIL: SSH (port 22) is not allowed"
  exit 1
fi

# Check we can actually reach the web server
RESPONSE=$(curl -sf http://localhost 2>/dev/null || true)
if ! echo "$RESPONSE" | grep -q "Firewall Test Page"; then
  echo "FAIL: Cannot reach web server on port 80"
  exit 1
fi

echo "PASS: Firewall rules are correctly configured"
exit 0
