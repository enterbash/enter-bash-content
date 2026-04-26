#!/bin/bash

if [ ! -f ~/ingress.yaml ]; then
  echo "FAIL: ~/ingress.yaml not found"
  exit 1
fi

if ! kubectl apply --dry-run=server -f ~/ingress.yaml 2>/dev/null; then
  echo "FAIL: ingress.yaml does not pass validation"
  exit 1
fi

# Check apiVersion
if ! grep -q 'apiVersion: networking.k8s.io/v1' ~/ingress.yaml; then
  echo "FAIL: apiVersion should be networking.k8s.io/v1"
  exit 1
fi

# Check pathType exists
if ! grep -q 'pathType:' ~/ingress.yaml; then
  echo "FAIL: pathType is required in networking.k8s.io/v1"
  exit 1
fi

# Check new-style backend
if ! grep -q 'service:' ~/ingress.yaml; then
  echo "FAIL: backend should use new service format"
  exit 1
fi

if ! grep -q 'name: web-svc' ~/ingress.yaml; then
  echo "FAIL: service name should be web-svc"
  exit 1
fi

echo "PASS: Ingress manifest is valid and correct"
exit 0
