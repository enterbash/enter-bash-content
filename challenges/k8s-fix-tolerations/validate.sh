#!/bin/bash

if [ ! -f ~/pod.yaml ]; then
  echo "FAIL: ~/pod.yaml not found"
  exit 1
fi

if ! kubectl apply --dry-run=client -f ~/pod.yaml 2>/dev/null; then
  echo "FAIL: pod.yaml does not pass validation"
  exit 1
fi

# Check first toleration: dedicated=gpu:NoSchedule with Equal operator
if ! grep -A4 'key: .dedicated' ~/pod.yaml | grep -q 'operator: .Equal'; then
  echo "FAIL: dedicated toleration should use operator: Equal"
  exit 1
fi

if ! grep -A4 'key: .dedicated' ~/pod.yaml | grep -q 'value: .gpu'; then
  echo "FAIL: dedicated toleration should have value: gpu"
  exit 1
fi

# Check second toleration: maintenance:NoExecute with Exists operator
if ! grep -A4 'key: .maintenance' ~/pod.yaml | grep -q 'operator: .Exists'; then
  echo "FAIL: maintenance toleration should use operator: Exists"
  exit 1
fi

if ! grep -q 'tolerationSeconds: 3600' ~/pod.yaml; then
  echo "FAIL: maintenance toleration should have tolerationSeconds: 3600"
  exit 1
fi

echo "PASS: Tolerations are correctly configured"
exit 0
