#!/bin/bash

# Verify docker daemon is accessible
if ! docker info > /dev/null 2>&1; then
  echo "FAIL: Docker daemon is not running or not accessible"
  exit 1
fi


if ! docker ps --format '{{.Names}}' | grep -q '^myserver$'; then
  echo "FAIL: myserver container is not running"
  exit 1
fi

echo "PASS: myserver container is running"
exit 0
