#!/bin/bash
set -e

cd ~/project 2>/dev/null || true

# Check both services are running
WEB_RUNNING=$(docker compose -f ~/project/docker-compose.yml ps --format '{{.Name}}' 2>/dev/null | grep -c 'web' || true)
API_RUNNING=$(docker compose -f ~/project/docker-compose.yml ps --format '{{.Name}}' 2>/dev/null | grep -c 'api' || true)

if [ "$WEB_RUNNING" -lt 1 ]; then
  echo "FAIL: web service is not running"
  exit 1
fi

if [ "$API_RUNNING" -lt 1 ]; then
  echo "FAIL: api service is not running"
  exit 1
fi

echo "PASS: both services are running"
exit 0
