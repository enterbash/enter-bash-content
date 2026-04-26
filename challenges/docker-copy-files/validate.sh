#!/bin/bash

# Check extracted.log exists on host
if [ ! -f ~/extracted.log ]; then
  echo "FAIL: ~/extracted.log not found on host"
  exit 1
fi

# Check it has content
if [ ! -s ~/extracted.log ]; then
  echo "FAIL: ~/extracted.log is empty"
  exit 1
fi

# Check inject.conf exists in container
if ! docker exec filebox test -f /etc/inject.conf; then
  echo "FAIL: /etc/inject.conf not found in container"
  exit 1
fi

CONTENT=$(docker exec filebox cat /etc/inject.conf 2>/dev/null)
if ! echo "$CONTENT" | grep -q 'mode=active'; then
  echo "FAIL: /etc/inject.conf doesn't contain mode=active"
  exit 1
fi

echo "PASS: files copied successfully in both directions"
exit 0
