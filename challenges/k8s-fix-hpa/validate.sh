#!/bin/bash
set -e

if [ ! -f ~/hpa.yaml ]; then
  echo "FAIL: ~/hpa.yaml not found"
  exit 1
fi

kubectl apply --dry-run=client -f ~/hpa.yaml 2>/dev/null
if [ $? -ne 0 ]; then
  echo "FAIL: hpa.yaml does not pass validation"
  exit 1
fi

if ! grep -q 'kind: HorizontalPodAutoscaler' ~/hpa.yaml; then
  echo "FAIL: kind should be HorizontalPodAutoscaler"
  exit 1
fi

if ! grep -q 'kind: Deployment' ~/hpa.yaml; then
  echo "FAIL: scaleTargetRef.kind should be Deployment"
  exit 1
fi

if ! grep -q 'name: web-app' ~/hpa.yaml; then
  echo "FAIL: scaleTargetRef.name should be web-app"
  exit 1
fi

if ! grep -q 'minReplicas: 2' ~/hpa.yaml; then
  echo "FAIL: minReplicas should be 2"
  exit 1
fi

if ! grep -q 'maxReplicas: 10' ~/hpa.yaml; then
  echo "FAIL: maxReplicas should be 10"
  exit 1
fi

echo "PASS: HPA manifest is valid and correct"
exit 0
