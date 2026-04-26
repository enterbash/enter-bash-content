#!/bin/bash

if [ ! -f ~/namespace.yaml ]; then
  echo "FAIL: ~/namespace.yaml not found"
  exit 1
fi

if ! kubectl apply --dry-run=server -f ~/namespace.yaml 2>/dev/null; then
  echo "FAIL: namespace.yaml does not pass validation"
  exit 1
fi

if ! grep -q 'kind: Namespace' ~/namespace.yaml; then
  echo "FAIL: kind should be Namespace"
  exit 1
fi

if ! grep -q 'name: staging' ~/namespace.yaml; then
  echo "FAIL: name should be staging"
  exit 1
fi

if ! grep -q 'env: staging' ~/namespace.yaml; then
  echo "FAIL: should have label env: staging"
  exit 1
fi

if ! grep -q 'team: backend' ~/namespace.yaml; then
  echo "FAIL: should have label team: backend"
  exit 1
fi

if ! grep -q 'description' ~/namespace.yaml; then
  echo "FAIL: should have description annotation"
  exit 1
fi

echo "PASS: Namespace is correctly configured"
exit 0
