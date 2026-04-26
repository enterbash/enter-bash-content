#!/bin/bash

# Verify docker daemon is accessible
if ! docker info > /dev/null 2>&1; then
  echo "FAIL: Docker daemon is not running or not accessible"
  exit 1
fi


if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q '^webapp:latest$'; then
  echo "FAIL: webapp:latest image not found"
  exit 1
fi

echo "PASS: webapp:latest image built successfully"
exit 0
