#!/bin/bash

if ! docker ps --format '{{.Names}}' | grep -q '^storebox-fixed$'; then
  echo "FAIL: storebox-fixed container is not running"
  exit 1
fi

# Check it can write to /data
if ! docker exec storebox-fixed sh -c 'echo test > /data/writetest.txt' 2>/dev/null; then
  echo "FAIL: cannot write to /data"
  exit 1
fi

# Check tmpfs mount
MOUNTS=$(docker inspect storebox-fixed --format '{{range .Mounts}}{{.Type}} {{end}}' 2>/dev/null)
TMPFS=$(docker inspect storebox-fixed --format '{{.HostConfig.Tmpfs}}' 2>/dev/null)
if ! echo "$TMPFS" | grep -q '/tmp'; then
  echo "FAIL: /tmp tmpfs mount not found"
  exit 1
fi

echo "PASS: storage fixed with correct permissions and tmpfs"
exit 0
