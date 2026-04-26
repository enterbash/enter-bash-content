#!/bin/bash

if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q '^signalapp:fixed$'; then
  echo "FAIL: signalapp:fixed image not found"
  exit 1
fi

# Check the entrypoint is exec form (not shell form)
EP=$(docker inspect signalapp:fixed --format '{{.Config.Entrypoint}}' 2>/dev/null)
if echo "$EP" | grep -q '/bin/sh'; then
  echo "FAIL: still using shell form entrypoint"
  exit 1
fi

echo "PASS: signal handling fixed with exec form entrypoint"
exit 0
