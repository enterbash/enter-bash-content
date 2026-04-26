#!/bin/bash
set -e

# Check both containers are running
if ! docker ps --format '{{.Names}}' | grep -q '^web$'; then
  echo "FAIL: web container is not running"
  exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -q '^client$'; then
  echo "FAIL: client container is not running"
  exit 1
fi

# Check client can reach web by name
RESULT=$(docker exec client curl -sf http://web:8080 2>/dev/null || true)
if [ -n "$RESULT" ]; then
  echo "PASS: client can reach web container"
  exit 0
else
  echo "FAIL: client cannot reach web container"
  exit 1
fi
