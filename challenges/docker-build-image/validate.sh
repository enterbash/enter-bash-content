#!/bin/bash
set -e

# Check that the myapp:latest image exists
if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q '^myapp:latest$'; then
  echo "FAIL: myapp:latest image not found"
  exit 1
fi

echo "PASS: myapp:latest image exists"
exit 0
