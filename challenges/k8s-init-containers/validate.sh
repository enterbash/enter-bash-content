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

if ! grep -q 'initContainers:' ~/pod.yaml; then
  echo "FAIL: initContainers section is missing"
  exit 1
fi

if ! grep -q 'name: content-init' ~/pod.yaml; then
  echo "FAIL: init container name should be content-init"
  exit 1
fi

if ! grep -q 'image: busybox' ~/pod.yaml; then
  echo "FAIL: init container image should be busybox"
  exit 1
fi

if ! grep -q '/work-dir' ~/pod.yaml; then
  echo "FAIL: init container should mount volume at /work-dir"
  exit 1
fi

echo "PASS: Init container is correctly configured"
exit 0
