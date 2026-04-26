#!/bin/bash
set -e

if [ ! -f ~/secret.yaml ] || [ ! -f ~/pod.yaml ]; then
  echo "FAIL: secret.yaml or pod.yaml not found"
  exit 1
fi

kubectl apply --dry-run=client -f ~/secret.yaml 2>/dev/null
if [ $? -ne 0 ]; then
  echo "FAIL: secret.yaml does not pass validation"
  exit 1
fi

kubectl apply --dry-run=client -f ~/pod.yaml 2>/dev/null
if [ $? -ne 0 ]; then
  echo "FAIL: pod.yaml does not pass validation"
  exit 1
fi

# Check Secret kind and name
if ! grep -q 'kind: Secret' ~/secret.yaml; then
  echo "FAIL: kind should be Secret"
  exit 1
fi

if ! grep -q 'name: db-credentials' ~/secret.yaml; then
  echo "FAIL: Secret name should be db-credentials"
  exit 1
fi

# Check Secret has username and password keys
if ! grep -q 'username' ~/secret.yaml; then
  echo "FAIL: Secret should have username key"
  exit 1
fi

if ! grep -q 'password' ~/secret.yaml; then
  echo "FAIL: Secret should have password key"
  exit 1
fi

# Check Pod references the secret
if ! grep -q 'db-credentials' ~/pod.yaml; then
  echo "FAIL: Pod should reference db-credentials secret"
  exit 1
fi

if ! grep -q 'DB_USER' ~/pod.yaml; then
  echo "FAIL: Pod should have DB_USER env var"
  exit 1
fi

if ! grep -q 'DB_PASS' ~/pod.yaml; then
  echo "FAIL: Pod should have DB_PASS env var"
  exit 1
fi

echo "PASS: Secret and Pod are correctly configured"
exit 0
