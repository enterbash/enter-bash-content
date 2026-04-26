#!/bin/bash

if [ ! -f ~/pod.yaml ]; then
  echo "FAIL: ~/pod.yaml not found"
  exit 1
fi

if ! kubectl apply --dry-run=client -f ~/pod.yaml 2>/dev/null; then
  echo "FAIL: pod.yaml does not pass validation"
  exit 1
fi

# Must NOT be privileged
if grep -q 'privileged: true' ~/pod.yaml; then
  echo "FAIL: privileged must be false"
  exit 1
fi

# Must run as non-root
if grep -q 'runAsUser: 0' ~/pod.yaml; then
  echo "FAIL: runAsUser must not be 0 (root)"
  exit 1
fi

if ! grep -q 'runAsUser: 1000' ~/pod.yaml; then
  echo "FAIL: runAsUser should be 1000"
  exit 1
fi

if ! grep -q 'runAsNonRoot: true' ~/pod.yaml; then
  echo "FAIL: runAsNonRoot should be true"
  exit 1
fi

if ! grep -q 'readOnlyRootFilesystem: true' ~/pod.yaml; then
  echo "FAIL: readOnlyRootFilesystem should be true"
  exit 1
fi

if ! grep -q 'allowPrivilegeEscalation: false' ~/pod.yaml; then
  echo "FAIL: allowPrivilegeEscalation should be false"
  exit 1
fi

echo "PASS: Pod security context is correctly configured"
exit 0
