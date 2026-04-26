#!/bin/bash

# Verify docker daemon is accessible
if ! docker info > /dev/null 2>&1; then
  echo "FAIL: Docker daemon is not running or not accessible"
  exit 1
fi


# Check that the myapp:latest image exists
if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q '^myapp:latest$'; then
  echo "FAIL: myapp:latest image not found"
  exit 1
fi

echo "PASS: myapp:latest image exists"
exit 0
