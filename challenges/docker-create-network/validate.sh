#!/bin/bash

# Check network exists
if ! docker network ls --format '{{.Name}}' | grep -q '^mynet$'; then
  echo "FAIL: mynet network not found"
  exit 1
fi

# Check containers are running
if ! docker ps --format '{{.Names}}' | grep -q '^web$'; then
  echo "FAIL: web container is not running"
  exit 1
fi

if ! docker ps --format '{{.Names}}' | grep -q '^tester$'; then
  echo "FAIL: tester container is not running"
  exit 1
fi

# Check both are on mynet
WEB_NET=$(docker inspect web --format '{{range $k,$v := .NetworkSettings.Networks}}{{$k}}{{end}}' 2>/dev/null)
if ! echo "$WEB_NET" | grep -q 'mynet'; then
  echo "FAIL: web is not on mynet network"
  exit 1
fi

TESTER_NET=$(docker inspect tester --format '{{range $k,$v := .NetworkSettings.Networks}}{{$k}}{{end}}' 2>/dev/null)
if ! echo "$TESTER_NET" | grep -q 'mynet'; then
  echo "FAIL: tester is not on mynet network"
  exit 1
fi

# Check connectivity
if ! docker exec tester ping -c 1 -W 2 web >/dev/null 2>&1; then
  echo "FAIL: tester cannot reach web"
  exit 1
fi

echo "PASS: containers communicating on custom network"
exit 0
