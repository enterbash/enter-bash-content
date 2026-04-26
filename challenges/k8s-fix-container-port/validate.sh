#!/bin/bash

if [ ! -f ~/pod.yaml ] || [ ! -f ~/service.yaml ]; then
  echo "FAIL: pod.yaml or service.yaml not found"
  exit 1
fi

if ! kubectl apply --dry-run=server -f ~/pod.yaml 2>/dev/null; then
  echo "FAIL: pod.yaml does not pass validation"
  exit 1
fi

if ! kubectl apply --dry-run=server -f ~/service.yaml 2>/dev/null; then
  echo "FAIL: service.yaml does not pass validation"
  exit 1
fi

if ! grep -q 'containerPort: 3000' ~/pod.yaml; then
  echo "FAIL: containerPort should be 3000"
  exit 1
fi

if ! grep -q 'port: 80' ~/service.yaml; then
  echo "FAIL: Service port should be 80"
  exit 1
fi

if ! grep -q 'targetPort: 3000' ~/service.yaml; then
  echo "FAIL: Service targetPort should be 3000"
  exit 1
fi

if ! grep -q 'app: node-app' ~/service.yaml; then
  echo "FAIL: Service selector should match Pod labels (app: node-app)"
  exit 1
fi

echo "PASS: Port configuration is correct"
exit 0
