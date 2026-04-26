#!/bin/bash

# Check container is running
if ! docker ps --format '{{.Names}}' | grep -q '^databox$'; then
  echo "FAIL: databox container is not running"
  exit 1
fi

# Check volume mount exists
MOUNTS=$(docker inspect databox --format '{{range .Mounts}}{{.Destination}}{{end}}' 2>/dev/null || true)
if ! echo "$MOUNTS" | grep -q '/data'; then
  echo "FAIL: /data volume mount not found"
  exit 1
fi

# Check config.txt is accessible inside container
if ! docker exec databox test -f /data/config.txt; then
  echo "FAIL: config.txt not accessible inside container"
  exit 1
fi

# Check output.txt was created
if ! docker exec databox test -f /data/output.txt; then
  echo "FAIL: output.txt not found in /data"
  exit 1
fi

echo "PASS: volume mounted correctly with data persistence"
exit 0
