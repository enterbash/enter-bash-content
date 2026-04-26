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

# Check POD_NAME uses metadata.name
if grep -q 'metadata.labels' ~/pod.yaml; then
  echo "FAIL: POD_NAME should use metadata.name, not metadata.labels"
  exit 1
fi

if ! grep -q 'metadata.name' ~/pod.yaml; then
  echo "FAIL: POD_NAME should use fieldPath: metadata.name"
  exit 1
fi

# Check NODE_NAME uses spec.nodeName
if grep -q 'spec.nodename' ~/pod.yaml; then
  echo "FAIL: NODE_NAME should use spec.nodeName (capital N)"
  exit 1
fi

if ! grep -q 'spec.nodeName' ~/pod.yaml; then
  echo "FAIL: NODE_NAME should use fieldPath: spec.nodeName"
  exit 1
fi

echo "PASS: Environment variables are correctly configured"
exit 0
