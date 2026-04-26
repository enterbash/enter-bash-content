#!/bin/bash
set -e

if ! docker ps --format '{{.Names}}' | grep -q '^readonly-web$'; then
  echo "FAIL: readonly-web container is not running"
  exit 1
fi

# Check read-only
RO=$(docker inspect readonly-web --format '{{.HostConfig.ReadonlyRootfs}}' 2>/dev/null)
if [ "$RO" != "true" ]; then
  echo "FAIL: root filesystem is not read-only"
  exit 1
fi

# Check tmpfs mounts exist
TMPFS=$(docker inspect readonly-web --format '{{.HostConfig.Tmpfs}}' 2>/dev/null)
if ! echo "$TMPFS" | grep -q '/var/cache/nginx'; then
  echo "FAIL: /var/cache/nginx tmpfs not found"
  exit 1
fi
if ! echo "$TMPFS" | grep -q '/var/run'; then
  echo "FAIL: /var/run tmpfs not found"
  exit 1
fi

# Verify write to root fails
if docker exec readonly-web touch /test-readonly.txt 2>/dev/null; then
  echo "FAIL: was able to write to read-only filesystem"
  exit 1
fi

echo "PASS: read-only container running with tmpfs mounts"
exit 0
