#!/bin/bash

if [ ! -f ~/pod.yaml ]; then
  echo "FAIL: ~/pod.yaml not found"
  exit 1
fi

if ! kubectl apply --dry-run=client -f ~/pod.yaml 2>/dev/null; then
  echo "FAIL: pod.yaml does not pass validation"
  exit 1
fi

# Check resource requests
if ! grep -q 'cpu: .100m.' ~/pod.yaml && ! grep -q "cpu: 100m" ~/pod.yaml && ! grep -q 'cpu: "100m"' ~/pod.yaml; then
  # Broader check
  if ! grep -A5 'requests:' ~/pod.yaml | grep -q '100m'; then
    echo "FAIL: CPU request should be 100m"
    exit 1
  fi
fi

if ! grep -A5 'requests:' ~/pod.yaml | grep -q '128Mi'; then
  echo "FAIL: Memory request should be 128Mi"
  exit 1
fi

# Check resource limits
if ! grep -A5 'limits:' ~/pod.yaml | grep -q '500m'; then
  echo "FAIL: CPU limit should be 500m"
  exit 1
fi

if ! grep -A5 'limits:' ~/pod.yaml | grep -q '256Mi'; then
  echo "FAIL: Memory limit should be 256Mi"
  exit 1
fi

echo "PASS: Resource limits are correctly configured"
exit 0
