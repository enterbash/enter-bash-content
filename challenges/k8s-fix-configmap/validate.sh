#!/bin/bash
set -e

if [ ! -f ~/configmap.yaml ] || [ ! -f ~/pod.yaml ]; then
  echo "FAIL: configmap.yaml or pod.yaml not found"
  exit 1
fi

# Validate ConfigMap
kubectl apply --dry-run=client -f ~/configmap.yaml 2>/dev/null
if [ $? -ne 0 ]; then
  echo "FAIL: configmap.yaml does not pass validation"
  exit 1
fi

# Validate Pod
kubectl apply --dry-run=client -f ~/pod.yaml 2>/dev/null
if [ $? -ne 0 ]; then
  echo "FAIL: pod.yaml does not pass validation"
  exit 1
fi

# Check ConfigMap data values are strings
if grep -P 'DATABASE_PORT: \d+$' ~/configmap.yaml | grep -vq '"'; then
  # Check if it's quoted
  if ! grep -q 'DATABASE_PORT: "5432"' ~/configmap.yaml && ! grep -q "DATABASE_PORT: '5432'" ~/configmap.yaml; then
    echo "FAIL: DATABASE_PORT must be a string (wrap in quotes)"
    exit 1
  fi
fi

if grep -P 'MAX_CONNECTIONS: \d+$' ~/configmap.yaml | grep -vq '"'; then
  if ! grep -q 'MAX_CONNECTIONS: "100"' ~/configmap.yaml && ! grep -q "MAX_CONNECTIONS: '100'" ~/configmap.yaml; then
    echo "FAIL: MAX_CONNECTIONS must be a string (wrap in quotes)"
    exit 1
  fi
fi

# Check Pod references correct ConfigMap name
CM_NAME=$(grep 'name:' ~/configmap.yaml | head -1 | awk '{print $2}')
if ! grep -q "name: $CM_NAME" ~/pod.yaml; then
  echo "FAIL: Pod configMapRef name must match ConfigMap name ($CM_NAME)"
  exit 1
fi

echo "PASS: ConfigMap and Pod manifests are valid"
exit 0
