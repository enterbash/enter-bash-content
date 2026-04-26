#!/bin/bash
set -e

if [ ! -f ~/role.yaml ] || [ ! -f ~/rolebinding.yaml ]; then
  echo "FAIL: role.yaml or rolebinding.yaml not found"
  exit 1
fi

kubectl apply --dry-run=client -f ~/role.yaml 2>/dev/null
if [ $? -ne 0 ]; then
  echo "FAIL: role.yaml does not pass validation"
  exit 1
fi

kubectl apply --dry-run=client -f ~/rolebinding.yaml 2>/dev/null
if [ $? -ne 0 ]; then
  echo "FAIL: rolebinding.yaml does not pass validation"
  exit 1
fi

# Check roleRef kind is Role (not ClusterRole)
if ! grep -A3 'roleRef:' ~/rolebinding.yaml | grep -q 'kind: Role'; then
  echo "FAIL: roleRef.kind should be Role"
  exit 1
fi

# Check roleRef name matches the Role name
if ! grep -A3 'roleRef:' ~/rolebinding.yaml | grep -q 'name: pod-reader'; then
  echo "FAIL: roleRef.name should be pod-reader"
  exit 1
fi

echo "PASS: RBAC configuration is correct"
exit 0
