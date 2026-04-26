#!/bin/bash

if [ ! -f ~/pod.yaml ]; then
  echo "FAIL: ~/pod.yaml not found"
  exit 1
fi

if ! kubectl apply --dry-run=client -f ~/pod.yaml 2>/dev/null; then
  echo "FAIL: pod.yaml does not pass validation"
  exit 1
fi

if ! grep -q 'name: log-shipper' ~/pod.yaml; then
  echo "FAIL: sidecar container name should be log-shipper"
  exit 1
fi

if ! grep -q 'image: busybox' ~/pod.yaml; then
  echo "FAIL: sidecar image should be busybox"
  exit 1
fi

# Check that log-shipper mounts the log volume
if ! grep -B5 -A5 'name: log-shipper' ~/pod.yaml | grep -q 'log-volume'; then
  echo "FAIL: sidecar should mount log-volume"
  exit 1
fi

# Check readOnly on sidecar mount
if ! grep -A10 'name: log-shipper' ~/pod.yaml | grep -q 'readOnly: true'; then
  echo "FAIL: sidecar volume mount should be readOnly: true"
  exit 1
fi

echo "PASS: Sidecar pattern is correctly implemented"
exit 0
