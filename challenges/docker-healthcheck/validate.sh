#!/bin/bash
set -e

if ! docker ps --format '{{.Names}}' | grep -q '^healthyweb$'; then
  echo "FAIL: healthyweb container is not running"
  exit 1
fi

# Check healthcheck is configured
HC=$(docker inspect healthyweb --format '{{.Config.Healthcheck}}' 2>/dev/null)
if [ -z "$HC" ] || [ "$HC" = "<nil>" ]; then
  echo "FAIL: no healthcheck configured"
  exit 1
fi

# Check health status (allow healthy or starting)
STATUS=$(docker inspect healthyweb --format '{{.State.Health.Status}}' 2>/dev/null)
if [ "$STATUS" = "healthy" ]; then
  echo "PASS: container is healthy with healthcheck configured"
  exit 0
fi

# If starting, wait a bit
if [ "$STATUS" = "starting" ]; then
  sleep 15
  STATUS=$(docker inspect healthyweb --format '{{.State.Health.Status}}' 2>/dev/null)
  if [ "$STATUS" = "healthy" ]; then
    echo "PASS: container is healthy with healthcheck configured"
    exit 0
  fi
fi

echo "FAIL: container health status is $STATUS (expected healthy)"
exit 1
