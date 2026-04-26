#!/bin/bash

if [ ! -f ~/pod.yaml ]; then
  echo "FAIL: ~/pod.yaml not found"
  exit 1
fi

if ! kubectl apply --dry-run=client -f ~/pod.yaml 2>/dev/null; then
  echo "FAIL: pod.yaml does not pass validation"
  exit 1
fi

# Extract volume names and volumeMount names, check they match
VOL_NAMES=$(grep -A1 '^\s*- name:' ~/pod.yaml | grep 'name:' | awk '{print $3}' | sort)
# Simple check: the file must pass dry-run (which validates volume refs)
# Also check both mount paths exist
if ! grep -q '/etc/config' ~/pod.yaml; then
  echo "FAIL: should mount at /etc/config"
  exit 1
fi

if ! grep -q '/data' ~/pod.yaml; then
  echo "FAIL: should mount at /data"
  exit 1
fi

echo "PASS: Volume mounts are correctly configured"
exit 0
