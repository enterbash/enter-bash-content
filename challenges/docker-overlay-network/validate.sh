#!/bin/bash
set -e

# Check swarm is active
SWARM=$(docker info --format '{{.Swarm.LocalNodeState}}' 2>/dev/null)
if [ "$SWARM" != "active" ]; then
  echo "FAIL: Docker Swarm is not initialized"
  exit 1
fi

# Check overlay network exists
DRIVER=$(docker network inspect app-overlay --format '{{.Driver}}' 2>/dev/null || true)
if [ "$DRIVER" != "overlay" ]; then
  echo "FAIL: app-overlay network not found or not overlay type"
  exit 1
fi

# Check service exists
if ! docker service ls --format '{{.Name}}' | grep -q '^web-service$'; then
  echo "FAIL: web-service not found"
  exit 1
fi

# Check replicas
REPLICAS=$(docker service ls --filter name=web-service --format '{{.Replicas}}' 2>/dev/null)
if ! echo "$REPLICAS" | grep -q '2/2'; then
  echo "FAIL: web-service should have 2/2 replicas (got $REPLICAS)"
  exit 1
fi

echo "PASS: overlay network and service configured correctly"
exit 0
