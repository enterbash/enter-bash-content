#!/bin/bash

if [ ! -f ~/pod.yaml ]; then
  echo "FAIL: ~/pod.yaml not found"
  exit 1
fi

if ! kubectl apply --dry-run=server -f ~/pod.yaml 2>/dev/null; then
  echo "FAIL: pod.yaml does not pass validation"
  exit 1
fi

if ! grep -q 'dnsPolicy: None' ~/pod.yaml; then
  echo "FAIL: dnsPolicy should be None"
  exit 1
fi

if ! grep -q 'dnsConfig:' ~/pod.yaml; then
  echo "FAIL: dnsConfig section is required"
  exit 1
fi

if ! grep -q '8.8.8.8' ~/pod.yaml; then
  echo "FAIL: nameservers should include 8.8.8.8"
  exit 1
fi

if ! grep -q '8.8.4.4' ~/pod.yaml; then
  echo "FAIL: nameservers should include 8.8.4.4"
  exit 1
fi

if ! grep -q 'svc.cluster.local' ~/pod.yaml; then
  echo "FAIL: searches should include svc.cluster.local"
  exit 1
fi

if ! grep -q 'ndots' ~/pod.yaml; then
  echo "FAIL: options should include ndots"
  exit 1
fi

echo "PASS: DNS policy is correctly configured"
exit 0
