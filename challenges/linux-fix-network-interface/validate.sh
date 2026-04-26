#!/bin/bash

# Check dummy0 exists and is UP
if ! ip link show dummy0 | grep -q 'UP'; then
  echo "FAIL: dummy0 interface is not UP"
  exit 1
fi

# Check correct IP is assigned
if ! ip addr show dummy0 | grep -q '10.0.0.10/24'; then
  echo "FAIL: dummy0 does not have IP 10.0.0.10/24"
  exit 1
fi

# Check wrong IP is removed
if ip addr show dummy0 | grep -q '192.168.99.99'; then
  echo "FAIL: Old IP 192.168.99.99 is still assigned"
  exit 1
fi

echo "PASS: Network interface is correctly configured"
exit 0
