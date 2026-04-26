#!/bin/bash
set -e

if ! docker ps --format '{{.Names}}' | grep -q '^redis-server$'; then
  echo "FAIL: redis-server container is not running"
  exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -q '^redis-client$'; then
  echo "FAIL: redis-client container is not running"
  exit 1
fi

# Check link exists (db alias should resolve)
if ! docker exec redis-client ping -c 1 -W 2 db >/dev/null 2>&1; then
  echo "FAIL: redis-client cannot reach 'db' (link not working)"
  exit 1
fi

echo "PASS: containers linked correctly"
exit 0
