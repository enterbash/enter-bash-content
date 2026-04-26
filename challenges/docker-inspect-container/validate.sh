#!/bin/bash

if [ ! -f ~/report.txt ]; then
  echo "FAIL: ~/report.txt not found"
  exit 1
fi

LINES=$(wc -l < ~/report.txt)
if [ "$LINES" -lt 4 ]; then
  echo "FAIL: report.txt should have at least 4 lines"
  exit 1
fi

# Check IP address line
IP=$(docker inspect mystery --format '{{range .NetworkSettings.Networks}}{{.IPAddress}}{{end}}' 2>/dev/null)
if ! grep -q "$IP" ~/report.txt; then
  echo "FAIL: IP address $IP not found in report"
  exit 1
fi

# Check image
if ! grep -qi 'nginx' ~/report.txt; then
  echo "FAIL: image name not found in report"
  exit 1
fi

# Check hostname
if ! grep -q 'myhost' ~/report.txt; then
  echo "FAIL: hostname not found in report"
  exit 1
fi

echo "PASS: report contains correct container info"
exit 0
