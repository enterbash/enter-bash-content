#!/bin/bash

if [ ! -f ~/sa.yaml ] || [ ! -f ~/rolebinding.yaml ]; then
  echo "FAIL: sa.yaml or rolebinding.yaml not found"
  exit 1
fi

if ! kubectl apply --dry-run=server -f ~/sa.yaml 2>/dev/null; then
  echo "FAIL: sa.yaml does not pass validation"
  exit 1
fi

if ! kubectl apply --dry-run=server -f ~/rolebinding.yaml 2>/dev/null; then
  echo "FAIL: rolebinding.yaml does not pass validation"
  exit 1
fi

if ! grep -q 'kind: ServiceAccount' ~/sa.yaml; then
  echo "FAIL: kind should be ServiceAccount"
  exit 1
fi

if ! grep -q 'name: app-deployer' ~/sa.yaml; then
  echo "FAIL: ServiceAccount name should be app-deployer"
  exit 1
fi

if ! grep -q 'role: deployer' ~/sa.yaml; then
  echo "FAIL: should have label role: deployer"
  exit 1
fi

if ! grep -q 'name: app-deployer-binding' ~/rolebinding.yaml; then
  echo "FAIL: RoleBinding name should be app-deployer-binding"
  exit 1
fi

if ! grep -q 'kind: ServiceAccount' ~/rolebinding.yaml; then
  echo "FAIL: subject kind should be ServiceAccount"
  exit 1
fi

if ! grep -q 'name: edit' ~/rolebinding.yaml; then
  echo "FAIL: roleRef name should be edit"
  exit 1
fi

echo "PASS: ServiceAccount and RoleBinding are correct"
exit 0
