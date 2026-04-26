#!/bin/bash
set -e

if ! docker ps --format '{{.Names}}' | grep -q '^limited$'; then
  echo "FAIL: limited container is not running"
  exit 1
fi

# Check memory limit (128MB = 134217728 bytes)
MEM=$(docker inspect limited --format '{{.HostConfig.Memory}}' 2>/dev/null)
if [ "$MEM" != "134217728" ]; then
  echo "FAIL: memory limit is not 128MB (got $MEM)"
  exit 1
fi

# Check CPU limit (0.5 CPUs = 500000000 NanoCpus)
CPU=$(docker inspect limited --format '{{.HostConfig.NanoCpus}}' 2>/dev/null)
if [ "$CPU" != "500000000" ]; then
  echo "FAIL: CPU limit is not 0.5 (got $CPU)"
  exit 1
fi

echo "PASS: resource limits correctly set"
exit 0
