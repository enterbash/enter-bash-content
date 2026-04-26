#!/bin/bash

# Check no stopped containers
STOPPED=$(docker ps -a --filter "status=exited" --format '{{.Names}}' | grep -c 'old' || true)
if [ "$STOPPED" -gt 0 ]; then
  echo "FAIL: there are still stopped containers"
  exit 1
fi

# Check no unused custom networks
UNUSED=$(docker network ls --format '{{.Name}}' | grep -c 'unused-net' || true)
if [ "$UNUSED" -gt 0 ]; then
  echo "FAIL: unused networks still exist"
  exit 1
fi

echo "PASS: Docker resources cleaned up"
exit 0
