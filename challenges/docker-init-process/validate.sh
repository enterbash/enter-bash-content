#!/bin/bash
set -e

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

# Alternative check: inspect the init field
INIT_PTR=$(docker inspect with-init --format '{{if .HostConfig.Init}}{{deref .HostConfig.Init}}{{end}}' 2>/dev/null || true)
if [ "$INIT_PTR" != "true" ]; then
  # Fallback: check PID 1 process name
  PID1=$(docker exec with-init ps -o comm= -p 1 2>/dev/null || true)
  if ! echo "$PID1" | grep -qi 'init\|tini\|docker'; then
    echo "FAIL: --init flag not detected"
    exit 1
  fi
fi

echo "PASS: init process configured correctly"
exit 0
