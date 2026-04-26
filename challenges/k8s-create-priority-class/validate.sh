#!/bin/bash
set -e

if [ ! -f ~/priorityclass.yaml ] || [ ! -f ~/pod.yaml ]; then
  echo "FAIL: priorityclass.yaml or pod.yaml not found"
  exit 1
fi

kubectl apply --dry-run=client -f ~/priorityclass.yaml 2>/dev/null
if [ $? -ne 0 ]; then
  echo "FAIL: priorityclass.yaml does not pass validation"
  exit 1
fi

kubectl apply --dry-run=client -f ~/pod.yaml 2>/dev/null
if [ $? -ne 0 ]; then
  echo "FAIL: pod.yaml does not pass validation"
  exit 1
fi

if ! grep -q 'kind: PriorityClass' ~/priorityclass.yaml; then
  echo "FAIL: kind should be PriorityClass"
  exit 1
fi

if ! grep -q 'name: high-priority' ~/priorityclass.yaml; then
  echo "FAIL: PriorityClass name should be high-priority"
  exit 1
fi

if ! grep -q 'value: 1000000' ~/priorityclass.yaml; then
  echo "FAIL: value should be 1000000"
  exit 1
fi

if ! grep -q 'globalDefault: false' ~/priorityclass.yaml; then
  echo "FAIL: globalDefault should be false"
  exit 1
fi

if ! grep -q 'name: critical-app' ~/pod.yaml; then
  echo "FAIL: Pod name should be critical-app"
  exit 1
fi

if ! grep -q 'priorityClassName: high-priority' ~/pod.yaml; then
  echo "FAIL: Pod should reference high-priority PriorityClass"
  exit 1
fi

echo "PASS: PriorityClass and Pod are correctly configured"
exit 0
