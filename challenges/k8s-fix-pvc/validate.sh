#!/bin/bash
set -e

if [ ! -f ~/pvc.yaml ]; then
  echo "FAIL: ~/pvc.yaml not found"
  exit 1
fi

kubectl apply --dry-run=client -f ~/pvc.yaml 2>/dev/null
if [ $? -ne 0 ]; then
  echo "FAIL: pvc.yaml does not pass validation"
  exit 1
fi

if ! grep -q 'ReadWriteOnce' ~/pvc.yaml; then
  echo "FAIL: accessMode should be ReadWriteOnce"
  exit 1
fi

if ! grep -q 'storage: 5Gi' ~/pvc.yaml; then
  echo "FAIL: storage request should be 5Gi"
  exit 1
fi

# Should NOT have cpu in resources.requests
if grep -A5 'requests:' ~/pvc.yaml | grep -q 'cpu:'; then
  echo "FAIL: PVC resources.requests should not contain cpu"
  exit 1
fi

echo "PASS: PVC manifest is valid and correct"
exit 0
