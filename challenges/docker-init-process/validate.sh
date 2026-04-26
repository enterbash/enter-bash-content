#!/bin/bash

# Verify docker daemon is accessible
if ! docker info > /dev/null 2>&1; then
  echo "FAIL: Docker daemon is not running or not accessible"
  exit 1
fi


if ! docker ps --format '{{.Names}}' | grep -q '^with-init$'; then
  echo "FAIL: with-init container is not running"
  exit 1
fi

# Check --init is enabled
INIT=$(docker inspect with-init --format '{{.HostConfig.Init}}' 2>/dev/null)
if [ "$INIT" != "true" ] && [ "$INIT" != "<nil>" ]; then
  # Check PID 1 directly
  PID1=$(docker exec with-init ps -o comm= -p 1 2>/dev/null || true)
  if ! echo "$PID1" | grep -qi 'init\|tini'; then
    echo "FAIL: with-init doesn't have init as PID 1 (got: $PID1)"
    exit 1
  fi
fi

# Verify PID 1 is an init process
PID1=$(docker exec with-init ps -o comm= -p 1 2>/dev/null || true)
if ! echo "$PID1" | grep -qi 'init\|tini'; then
  echo "FAIL: --init flag not set — PID 1 is '$PID1', expected init/tini"
  exit 1
fi

echo "PASS: init process configured correctly"
exit 0
