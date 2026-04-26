#!/bin/bash

if [ ! -f ~/limitrange.yaml ]; then
  echo "FAIL: ~/limitrange.yaml not found"
  exit 1
fi

if ! kubectl apply --dry-run=client -f ~/limitrange.yaml 2>/dev/null; then
  echo "FAIL: limitrange.yaml does not pass validation"
  exit 1
fi

if ! grep -q 'kind: LimitRange' ~/limitrange.yaml; then
  echo "FAIL: kind should be LimitRange"
  exit 1
fi

if ! grep -q 'name: default-limits' ~/limitrange.yaml; then
  echo "FAIL: name should be default-limits"
  exit 1
fi

if ! grep -q 'type: Container' ~/limitrange.yaml; then
  echo "FAIL: type should be Container"
  exit 1
fi

if ! grep -q 'default:' ~/limitrange.yaml; then
  echo "FAIL: default limits should be set"
  exit 1
fi

if ! grep -q 'defaultRequest:' ~/limitrange.yaml; then
  echo "FAIL: defaultRequest should be set"
  exit 1
fi

if ! grep -q 'max:' ~/limitrange.yaml; then
  echo "FAIL: max limits should be set"
  exit 1
fi

if ! grep -q 'min:' ~/limitrange.yaml; then
  echo "FAIL: min limits should be set"
  exit 1
fi

echo "PASS: LimitRange is correctly configured"
exit 0
