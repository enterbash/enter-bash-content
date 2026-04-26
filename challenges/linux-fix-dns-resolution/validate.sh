#!/bin/bash
set -e

# Check that resolv.conf has valid nameservers
if ! grep -qE '^nameserver\s+(8\.8\.8\.8|8\.8\.4\.4|1\.1\.1\.1|1\.0\.0\.1|9\.9\.9\.9)' /etc/resolv.conf; then
  echo "FAIL: /etc/resolv.conf does not contain a valid public nameserver"
  exit 1
fi

# Check that DNS resolution works
if ! nslookup google.com > /dev/null 2>&1; then
  # Try host as fallback
  if ! host google.com > /dev/null 2>&1; then
    echo "FAIL: DNS resolution is still not working"
    exit 1
  fi
fi

echo "PASS: DNS resolution is working"
exit 0
