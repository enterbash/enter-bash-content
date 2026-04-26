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

if grep -q 'ngnix' ~/pod.yaml; then
  echo "FAIL: image name has a typo (ngnix)"
  exit 1
fi

if grep -q 'latst' ~/pod.yaml; then
  echo "FAIL: image tag has a typo (latst)"
  exit 1
fi

if ! grep -q 'image: nginx:1.25' ~/pod.yaml; then
  echo "FAIL: image should be nginx:1.25"
  exit 1
fi

echo "PASS: Image reference is correct"
exit 0
