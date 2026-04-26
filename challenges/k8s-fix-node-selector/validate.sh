#!/bin/bash
set -e

if [ ! -f ~/pod.yaml ]; then
  echo "FAIL: ~/pod.yaml not found"
  exit 1
fi

kubectl apply --dry-run=client -f ~/pod.yaml 2>/dev/null
if [ $? -ne 0 ]; then
  echo "FAIL: pod.yaml does not pass validation"
  exit 1
fi

# Check nodeSelector exists
if ! grep -q 'nodeSelector:' ~/pod.yaml; then
  echo "FAIL: nodeSelector is missing"
  exit 1
fi

# Check affinity exists
if ! grep -q 'affinity:' ~/pod.yaml; then
  echo "FAIL: affinity is missing"
  exit 1
fi

# Check nodeAffinity
if ! grep -q 'nodeAffinity:' ~/pod.yaml; then
  echo "FAIL: nodeAffinity is missing"
  exit 1
fi

echo "PASS: Node selector and affinity are correctly configured"
exit 0
