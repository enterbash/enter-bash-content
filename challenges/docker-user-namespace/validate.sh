#!/bin/bash
set -e

if ! docker ps --format '{{.Names}}' | grep -q '^safebox$'; then
  echo "FAIL: safebox container is not running"
  exit 1
fi

UID_CHECK=$(docker exec safebox id -u 2>/dev/null)
if [ "$UID_CHECK" = "0" ]; then
  echo "FAIL: container is running as root (uid 0)"
  exit 1
fi

if [ "$UID_CHECK" != "1001" ]; then
  echo "FAIL: container should run as uid 1001 (got $UID_CHECK)"
  exit 1
fi

echo "PASS: container running as non-root user (uid $UID_CHECK)"
exit 0
