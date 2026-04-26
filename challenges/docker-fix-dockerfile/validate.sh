#!/bin/bash

if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q '^webapp:latest$'; then
  echo "FAIL: webapp:latest image not found"
  exit 1
fi

echo "PASS: webapp:latest image built successfully"
exit 0
