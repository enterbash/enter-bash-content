#!/bin/bash
set -e

if [ ! -f ~/deployment.yaml ]; then
  echo "FAIL: ~/deployment.yaml not found"
  exit 1
fi

kubectl apply --dry-run=client -f ~/deployment.yaml 2>/dev/null
if [ $? -ne 0 ]; then
  echo "FAIL: deployment.yaml does not pass validation"
  exit 1
fi

if ! grep -q 'type: RollingUpdate' ~/deployment.yaml; then
  echo "FAIL: strategy type should be RollingUpdate"
  exit 1
fi

if ! grep -q 'maxSurge:' ~/deployment.yaml; then
  echo "FAIL: maxSurge should be configured"
  exit 1
fi

if ! grep -q 'maxUnavailable:' ~/deployment.yaml; then
  echo "FAIL: maxUnavailable should be configured"
  exit 1
fi

if ! grep -q 'minReadySeconds:' ~/deployment.yaml; then
  echo "FAIL: minReadySeconds should be set"
  exit 1
fi

echo "PASS: Rolling update strategy is correctly configured"
exit 0
