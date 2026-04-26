#!/bin/bash
set -e

# Check network exists with correct subnet
SUBNET=$(docker network inspect appnet --format '{{range .IPAM.Config}}{{.Subnet}}{{end}}' 2>/dev/null || true)
if [ "$SUBNET" != "172.20.0.0/16" ]; then
  echo "FAIL: appnet subnet is not 172.20.0.0/16 (got $SUBNET)"
  exit 1
fi

# Check webhost is running with correct IP
if ! docker ps --format '{{.Names}}' | grep -q '^webhost$'; then
  echo "FAIL: webhost container is not running"
  exit 1
fi

WEBIP=$(docker inspect webhost --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null)
if [ "$WEBIP" != "172.20.0.10" ]; then
  echo "FAIL: webhost IP is not 172.20.0.10 (got $WEBIP)"
  exit 1
fi

# Check checker can reach webhost
if ! docker ps --format '{{.Names}}' | grep -q '^checker$'; then
  echo "FAIL: checker container is not running"
  exit 1
fi

if ! docker exec checker ping -c 1 -W 2 172.20.0.10 >/dev/null 2>&1; then
  echo "FAIL: checker cannot reach webhost"
  exit 1
fi

echo "PASS: bridge network configured correctly"
exit 0
