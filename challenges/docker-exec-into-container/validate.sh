#!/bin/bash

if ! docker ps --format '{{.Names}}' | grep -q '^workbox$'; then
  echo "FAIL: workbox container is not running"
  exit 1
fi

# Check hello.txt
CONTENT=$(docker exec workbox cat /tmp/hello.txt 2>/dev/null || true)
if ! echo "$CONTENT" | grep -q 'Hello from exec'; then
  echo "FAIL: /tmp/hello.txt doesn't contain 'Hello from exec'"
  exit 1
fi

# Check curl installed
if ! docker exec workbox which curl >/dev/null 2>&1; then
  echo "FAIL: curl is not installed"
  exit 1
fi

# Check /app/logs directory
if ! docker exec workbox test -d /app/logs; then
  echo "FAIL: /app/logs directory not found"
  exit 1
fi

echo "PASS: all exec tasks completed"
exit 0
