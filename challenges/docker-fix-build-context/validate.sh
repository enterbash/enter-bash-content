#!/bin/bash

if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q '^slim-project:latest$'; then
  echo "FAIL: slim-project:latest image not found"
  exit 1
fi

# Check .dockerignore exists
if [ ! -f ~/bigproject/.dockerignore ]; then
  echo "FAIL: .dockerignore not found"
  exit 1
fi

# Check excluded files are not in image
if docker run --rm slim-project:latest test -d /app/data 2>/dev/null; then
  echo "FAIL: data/ directory should not be in the image"
  exit 1
fi

if docker run --rm slim-project:latest test -d /app/node_modules 2>/dev/null; then
  echo "FAIL: node_modules/ should not be in the image"
  exit 1
fi

if docker run --rm slim-project:latest test -f /app/app.log 2>/dev/null; then
  echo "FAIL: *.log files should not be in the image"
  exit 1
fi

echo "PASS: build context optimized with .dockerignore"
exit 0
