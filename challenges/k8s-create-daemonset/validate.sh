#!/bin/bash

if [ ! -f ~/daemonset.yaml ]; then
  echo "FAIL: ~/daemonset.yaml not found"
  exit 1
fi

if ! kubectl apply --dry-run=client -f ~/daemonset.yaml 2>/dev/null; then
  echo "FAIL: daemonset.yaml does not pass validation"
  exit 1
fi

if ! grep -q 'kind: DaemonSet' ~/daemonset.yaml; then
  echo "FAIL: kind should be DaemonSet"
  exit 1
fi

if ! grep -q 'name: log-collector' ~/daemonset.yaml; then
  echo "FAIL: DaemonSet name should be log-collector"
  exit 1
fi

if ! grep -q 'image: fluentd' ~/daemonset.yaml; then
  echo "FAIL: image should be fluentd"
  exit 1
fi

if ! grep -q '/var/log' ~/daemonset.yaml; then
  echo "FAIL: should mount /var/log"
  exit 1
fi

if ! grep -q 'hostPath:' ~/daemonset.yaml; then
  echo "FAIL: should use hostPath volume"
  exit 1
fi

if ! grep -q 'app: log-collector' ~/daemonset.yaml; then
  echo "FAIL: labels should include app: log-collector"
  exit 1
fi

echo "PASS: DaemonSet manifest is valid and correct"
exit 0
