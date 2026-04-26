#!/bin/bash

# Verify docker daemon is accessible
if ! docker info > /dev/null 2>&1; then
  echo "FAIL: Docker daemon is not running or not accessible"
  exit 1
fi


if [ ! -f ~/savetest.tar ]; then
  echo "FAIL: ~/savetest.tar not found"
  exit 1
fi

if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q '^restored:v1$'; then
  echo "FAIL: restored:v1 image not found"
  exit 1
fi

OUTPUT=$(docker run --rm restored:v1 2>/dev/null || true)
if ! echo "$OUTPUT" | grep -q 'save test'; then
  echo "FAIL: restored image doesn't produce expected output"
  exit 1
fi

echo "PASS: image saved and restored correctly"
exit 0
