#!/bin/bash

if [ ! -f ~/quota.yaml ]; then
  echo "FAIL: ~/quota.yaml not found"
  exit 1
fi

if ! kubectl apply --dry-run=client -f ~/quota.yaml 2>/dev/null; then
  echo "FAIL: quota.yaml does not pass validation"
  exit 1
fi

if ! grep -q 'kind: ResourceQuota' ~/quota.yaml; then
  echo "FAIL: kind should be ResourceQuota"
  exit 1
fi

if ! grep -q 'name: team-quota' ~/quota.yaml; then
  echo "FAIL: name should be team-quota"
  exit 1
fi

if ! grep -q 'pods:' ~/quota.yaml; then
  echo "FAIL: should have pods quota"
  exit 1
fi

if ! grep -q 'requests.cpu:' ~/quota.yaml; then
  echo "FAIL: should have requests.cpu quota"
  exit 1
fi

if ! grep -q 'requests.memory:' ~/quota.yaml; then
  echo "FAIL: should have requests.memory quota"
  exit 1
fi

if ! grep -q 'limits.cpu:' ~/quota.yaml; then
  echo "FAIL: should have limits.cpu quota"
  exit 1
fi

if ! grep -q 'limits.memory:' ~/quota.yaml; then
  echo "FAIL: should have limits.memory quota"
  exit 1
fi

if ! grep -q 'services:' ~/quota.yaml; then
  echo "FAIL: should have services quota"
  exit 1
fi

echo "PASS: ResourceQuota is correctly configured"
exit 0
