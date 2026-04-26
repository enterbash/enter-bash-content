#!/bin/bash

if [ ! -f ~/statefulset.yaml ]; then
  echo "FAIL: ~/statefulset.yaml not found"
  exit 1
fi

if ! kubectl apply --dry-run=client -f ~/statefulset.yaml 2>/dev/null; then
  echo "FAIL: statefulset.yaml does not pass validation"
  exit 1
fi

if ! grep -q 'kind: StatefulSet' ~/statefulset.yaml; then
  echo "FAIL: should contain a StatefulSet"
  exit 1
fi

if ! grep -q 'serviceName:' ~/statefulset.yaml; then
  echo "FAIL: StatefulSet requires serviceName field"
  exit 1
fi

if ! grep -q 'clusterIP: None' ~/statefulset.yaml; then
  echo "FAIL: headless Service must have clusterIP: None"
  exit 1
fi

if ! grep -q 'replicas: 3' ~/statefulset.yaml; then
  echo "FAIL: replicas should be 3"
  exit 1
fi

echo "PASS: StatefulSet manifest is valid and correct"
exit 0
