#!/bin/bash

if [ ! -f ~/job.yaml ]; then
  echo "FAIL: ~/job.yaml not found"
  exit 1
fi

if ! kubectl apply --dry-run=client -f ~/job.yaml 2>/dev/null; then
  echo "FAIL: job.yaml does not pass validation"
  exit 1
fi

if ! grep -q 'kind: Job' ~/job.yaml; then
  echo "FAIL: kind should be Job"
  exit 1
fi

if ! grep -q 'name: data-processor' ~/job.yaml; then
  echo "FAIL: Job name should be data-processor"
  exit 1
fi

if ! grep -q 'image: busybox' ~/job.yaml; then
  echo "FAIL: image should be busybox"
  exit 1
fi

if ! grep -q 'backoffLimit:' ~/job.yaml; then
  echo "FAIL: backoffLimit should be set"
  exit 1
fi

if ! grep -q 'restartPolicy: Never' ~/job.yaml; then
  echo "FAIL: restartPolicy should be Never"
  exit 1
fi

echo "PASS: Job manifest is valid and correct"
exit 0
