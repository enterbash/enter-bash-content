#!/bin/bash

if [ ! -f ~/deployment.yaml ]; then
  echo "FAIL: ~/deployment.yaml not found"
  exit 1
fi

if ! kubectl apply --dry-run=client -f ~/deployment.yaml 2>/dev/null; then
  echo "FAIL: deployment.yaml does not pass validation"
  exit 1
fi

# Check kind
if ! grep -q 'kind: Deployment' ~/deployment.yaml; then
  echo "FAIL: kind should be Deployment"
  exit 1
fi

# Check name
if ! grep -q 'name: nginx-deploy' ~/deployment.yaml; then
  echo "FAIL: Deployment name should be nginx-deploy"
  exit 1
fi

# Check replicas
if ! grep -q 'replicas: 3' ~/deployment.yaml; then
  echo "FAIL: replicas should be 3"
  exit 1
fi

# Check image
if ! grep -q 'image: nginx:1.25' ~/deployment.yaml; then
  echo "FAIL: image should be nginx:1.25"
  exit 1
fi

# Check container port
if ! grep -q 'containerPort: 80' ~/deployment.yaml; then
  echo "FAIL: containerPort should be 80"
  exit 1
fi

# Check label
if ! grep -q 'app: nginx' ~/deployment.yaml; then
  echo "FAIL: labels should include app: nginx"
  exit 1
fi

echo "PASS: Deployment manifest is valid and correct"
exit 0
