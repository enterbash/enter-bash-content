#!/bin/bash
set -e

# Check the file exists
if [ ! -f ~/service.yaml ]; then
  echo "FAIL: ~/service.yaml not found"
  exit 1
fi

# Must pass dry-run validation
kubectl apply --dry-run=client -f ~/service.yaml 2>/dev/null
if [ $? -ne 0 ]; then
  echo "FAIL: service.yaml does not pass validation"
  exit 1
fi

# Check apiVersion is v1
API=$(grep 'apiVersion:' ~/service.yaml | head -1 | awk '{print $2}')
if [ "$API" != "v1" ]; then
  echo "FAIL: apiVersion should be v1, got $API"
  exit 1
fi

# Check selector has app: web-app
if ! grep -q 'app: web-app' ~/service.yaml; then
  echo "FAIL: selector should match app: web-app"
  exit 1
fi

# Check port is 80 (integer)
if ! grep -q 'port: 80' ~/service.yaml; then
  echo "FAIL: port should be 80 (integer)"
  exit 1
fi

# Check targetPort is 8080 (integer)
if ! grep -q 'targetPort: 8080' ~/service.yaml; then
  echo "FAIL: targetPort should be 8080 (integer)"
  exit 1
fi

echo "PASS: Service manifest is valid and correct"
exit 0
