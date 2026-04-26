#!/bin/bash
set -e

if ! docker images --format '{{.Repository}}:{{.Tag}}' | grep -q '^argapp:latest$'; then
  echo "FAIL: argapp:latest image not found"
  exit 1
fi

OUTPUT=$(docker run --rm argapp:latest cat /app/version.txt 2>/dev/null || true)
if ! echo "$OUTPUT" | grep -q '2.0.0'; then
  echo "FAIL: version.txt doesn't contain 2.0.0 (got: $OUTPUT)"
  exit 1
fi

if ! echo "$OUTPUT" | grep -q 'production'; then
  echo "FAIL: version.txt doesn't contain production (got: $OUTPUT)"
  exit 1
fi

echo "PASS: build args working correctly"
exit 0
