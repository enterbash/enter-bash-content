#!/bin/bash

if ! docker ps --format '{{.Names}}' | grep -q '^dnsbox-fixed$'; then
  echo "FAIL: dnsbox-fixed container is not running"
  exit 1
fi

# Check DNS config
DNS=$(docker inspect dnsbox-fixed --format '{{range .HostConfig.DNS}}{{.}}{{end}}' 2>/dev/null)
if ! echo "$DNS" | grep -q '8.8.8.8'; then
  echo "FAIL: DNS is not set to 8.8.8.8 (got $DNS)"
  exit 1
fi

echo "PASS: DNS configured correctly"
exit 0
