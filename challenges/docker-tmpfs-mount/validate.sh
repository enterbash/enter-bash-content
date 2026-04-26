#!/bin/bash

if ! docker ps --format '{{.Names}}' | grep -q '^tmpbox$'; then
  echo "FAIL: tmpbox container is not running"
  exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -q '^securebox$'; then
  echo "FAIL: securebox container is not running"
  exit 1
fi

# Check tmpfs on tmpbox
TMPFS1=$(docker inspect tmpbox --format '{{.HostConfig.Tmpfs}}' 2>/dev/null)
if ! echo "$TMPFS1" | grep -q '/app/cache'; then
  echo "FAIL: /app/cache tmpfs not found on tmpbox"
  exit 1
fi

# Check tmpfs on securebox
TMPFS2=$(docker inspect securebox --format '{{.HostConfig.Tmpfs}}' 2>/dev/null)
if ! echo "$TMPFS2" | grep -q '/run/secrets'; then
  echo "FAIL: /run/secrets tmpfs not found on securebox"
  exit 1
fi

echo "PASS: tmpfs mounts configured correctly"
exit 0
