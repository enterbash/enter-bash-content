#!/bin/bash

# Verify docker daemon is accessible
if ! docker info > /dev/null 2>&1; then
  echo "FAIL: Docker daemon is not running or not accessible"
  exit 1
fi


# Check always-up
POL1=$(docker inspect always-up --format '{{.HostConfig.RestartPolicy.Name}}' 2>/dev/null || true)
if [ "$POL1" != "always" ]; then
  echo "FAIL: always-up restart policy is '$POL1' (expected 'always')"
  exit 1
fi

# Check on-fail
POL2=$(docker inspect on-fail --format '{{.HostConfig.RestartPolicy.Name}}' 2>/dev/null || true)
MAX2=$(docker inspect on-fail --format '{{.HostConfig.RestartPolicy.MaximumRetryCount}}' 2>/dev/null || true)
if [ "$POL2" != "on-failure" ]; then
  echo "FAIL: on-fail restart policy is '$POL2' (expected 'on-failure')"
  exit 1
fi
if [ "$MAX2" != "3" ]; then
  echo "FAIL: on-fail max retries is '$MAX2' (expected '3')"
  exit 1
fi

# Check unless-manual
POL3=$(docker inspect unless-manual --format '{{.HostConfig.RestartPolicy.Name}}' 2>/dev/null || true)
if [ "$POL3" != "unless-stopped" ]; then
  echo "FAIL: unless-manual restart policy is '$POL3' (expected 'unless-stopped')"
  exit 1
fi

echo "PASS: all restart policies configured correctly"
exit 0
