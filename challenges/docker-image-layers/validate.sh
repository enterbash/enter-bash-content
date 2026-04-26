#!/bin/bash

# Verify docker daemon is accessible
if ! docker info > /dev/null 2>&1; then
  echo "FAIL: Docker daemon is not running or not accessible"
  exit 1
fi


if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q '^optimized:latest$'; then
  echo "FAIL: optimized:latest image not found"
  exit 1
fi

# Compare sizes
BLOATED_SIZE=$(docker images bloated:latest --format '{{.Size}}' | head -1)
OPTIMIZED_SIZE=$(docker images optimized:latest --format '{{.Size}}' | head -1)

# Get sizes in bytes for comparison
BLOATED_BYTES=$(docker inspect bloated:latest --format '{{.Size}}' 2>/dev/null || echo "999999999")
OPTIMIZED_BYTES=$(docker inspect optimized:latest --format '{{.Size}}' 2>/dev/null || echo "999999999")

if [ "$OPTIMIZED_BYTES" -ge "$BLOATED_BYTES" ]; then
  echo "FAIL: optimized image ($OPTIMIZED_SIZE) is not smaller than bloated ($BLOATED_SIZE)"
  exit 1
fi

echo "PASS: optimized ($OPTIMIZED_SIZE) is smaller than bloated ($BLOATED_SIZE)"
exit 0
