#!/bin/bash

# Check container is running
if ! docker ps --format '{{.Names}}' | grep -q '^webserver$'; then
  echo "FAIL: webserver container is not running"
  exit 1
fi

# Check port mapping
PORT_MAP=$(docker port webserver 80 2>/dev/null || true)
if [ -z "$PORT_MAP" ]; then
  echo "FAIL: port 80 is not mapped"
  exit 1
fi

# Check accessibility
RESULT=$(curl -sf http://localhost:8080 2>/dev/null || true)
if [ -z "$RESULT" ]; then
  echo "FAIL: cannot reach webserver on port 8080"
  exit 1
fi

echo "PASS: webserver is accessible on port 8080"
exit 0
