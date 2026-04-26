#!/bin/bash
set -e

# Check service file exists
if [ ! -f /etc/systemd/system/myapp.service ]; then
  echo "FAIL: /etc/systemd/system/myapp.service does not exist"
  exit 1
fi

# Check service is enabled
if ! systemctl is-enabled myapp > /dev/null 2>&1; then
  echo "FAIL: myapp service is not enabled"
  exit 1
fi

# Check service is running
if ! systemctl is-active myapp > /dev/null 2>&1; then
  echo "FAIL: myapp service is not running"
  exit 1
fi

# Check the app responds
sleep 1
RESPONSE=$(curl -sf http://localhost:8080 2>/dev/null || true)
if ! echo "$RESPONSE" | grep -q 'myapp is running'; then
  echo "FAIL: myapp is not responding on port 8080"
  exit 1
fi

echo "PASS: systemd service is running and enabled"
exit 0
