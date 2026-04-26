#!/bin/bash
set -e

if ! docker ps --format '{{.Names}}' | grep -q '^permbox$'; then
  echo "FAIL: permbox container is not running"
  exit 1
fi

# Check it's running as non-root
UID_CHECK=$(docker exec permbox id -u 2>/dev/null)
if [ "$UID_CHECK" = "0" ]; then
  echo "FAIL: container is running as root"
  exit 1
fi

# Check data directory is writable
if ! docker exec permbox test -w /app/data; then
  echo "FAIL: /app/data is not writable"
  exit 1
fi

echo "PASS: container running as non-root with correct permissions"
exit 0
