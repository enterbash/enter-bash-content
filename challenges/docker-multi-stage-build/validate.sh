#!/bin/bash
set -e

if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q '^goapp:latest$'; then
  echo "FAIL: goapp:latest image not found"
  exit 1
fi

# Check image size is under 50MB
SIZE=$(docker images goapp:latest --format '{{.Size}}')
# Parse size - convert to MB
if echo "$SIZE" | grep -q 'GB'; then
  echo "FAIL: image is ${SIZE}, must be under 50MB"
  exit 1
fi

if echo "$SIZE" | grep -q 'MB'; then
  NUM=$(echo "$SIZE" | sed 's/MB//' | cut -d'.' -f1)
  if [ "$NUM" -ge 50 ]; then
    echo "FAIL: image is ${SIZE}, must be under 50MB"
    exit 1
  fi
fi

echo "PASS: goapp:latest image is ${SIZE} - nice and small!"
exit 0
