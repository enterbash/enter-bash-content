#!/bin/bash
set -e

if [ ! -f ~/deployment.yaml ] || [ ! -f ~/service.yaml ]; then
  echo "FAIL: deployment.yaml or service.yaml not found"
  exit 1
fi

kubectl apply --dry-run=client -f ~/deployment.yaml 2>/dev/null
if [ $? -ne 0 ]; then
  echo "FAIL: deployment.yaml does not pass validation"
  exit 1
fi

kubectl apply --dry-run=client -f ~/service.yaml 2>/dev/null
if [ $? -ne 0 ]; then
  echo "FAIL: service.yaml does not pass validation"
  exit 1
fi

# All selectors should use app: api-server
if ! grep -A2 'matchLabels:' ~/deployment.yaml | grep -q 'app: api-server'; then
  echo "FAIL: Deployment matchLabels should use app: api-server"
  exit 1
fi

if ! grep -A2 'selector:' ~/service.yaml | grep -q 'app: api-server'; then
  echo "FAIL: Service selector should use app: api-server"
  exit 1
fi

echo "PASS: Label selectors are correctly aligned"
exit 0
