#!/bin/bash
set -e

if ! docker ps --format '{{.Names}}' | grep -q '^webapp-fixed$'; then
  echo "FAIL: webapp-fixed container is not running"
  exit 1
fi

# Check that config.json is mounted
if ! docker exec webapp-fixed test -f /app/config.json; then
  echo "FAIL: /app/config.json not found in container"
  exit 1
fi

echo "PASS: webapp-fixed is running with config"
exit 0
