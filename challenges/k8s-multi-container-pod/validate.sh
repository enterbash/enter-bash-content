#!/bin/bash

if [ ! -f ~/pod.yaml ]; then
  echo "FAIL: ~/pod.yaml not found"
  exit 1
fi

if ! kubectl apply --dry-run=client -f ~/pod.yaml 2>/dev/null; then
  echo "FAIL: pod.yaml does not pass validation"
  exit 1
fi

if ! grep -q 'name: multi-container' ~/pod.yaml; then
  echo "FAIL: Pod name should be multi-container"
  exit 1
fi

if ! grep -q 'name: web' ~/pod.yaml; then
  echo "FAIL: should have container named web"
  exit 1
fi

if ! grep -q 'name: content' ~/pod.yaml; then
  echo "FAIL: should have container named content"
  exit 1
fi

if ! grep -q 'image: nginx' ~/pod.yaml; then
  echo "FAIL: web container should use nginx image"
  exit 1
fi

if ! grep -q 'image: busybox' ~/pod.yaml; then
  echo "FAIL: content container should use busybox image"
  exit 1
fi

if ! grep -q 'shared-data' ~/pod.yaml; then
  echo "FAIL: should have shared-data volume"
  exit 1
fi

if ! grep -q 'emptyDir' ~/pod.yaml; then
  echo "FAIL: should use emptyDir volume"
  exit 1
fi

echo "PASS: Multi-container pod is correctly configured"
exit 0
