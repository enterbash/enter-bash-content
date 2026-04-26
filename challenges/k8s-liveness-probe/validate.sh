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

# Check livenessProbe exists
if ! grep -q 'livenessProbe:' ~/pod.yaml; then
  echo "FAIL: livenessProbe is missing"
  exit 1
fi

# Check readinessProbe exists
if ! grep -q 'readinessProbe:' ~/pod.yaml; then
  echo "FAIL: readinessProbe is missing"
  exit 1
fi

# Check httpGet
if ! grep -q 'httpGet:' ~/pod.yaml; then
  echo "FAIL: probes should use httpGet"
  exit 1
fi

# Check initialDelaySeconds
if ! grep -q 'initialDelaySeconds:' ~/pod.yaml; then
  echo "FAIL: initialDelaySeconds is missing"
  exit 1
fi

# Check periodSeconds
if ! grep -q 'periodSeconds:' ~/pod.yaml; then
  echo "FAIL: periodSeconds is missing"
  exit 1
fi

echo "PASS: Liveness and readiness probes are correctly configured"
exit 0
