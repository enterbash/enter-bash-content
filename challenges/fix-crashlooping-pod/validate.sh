#!/bin/bash
STATUS=$(kubectl get pod web-app -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotFound")
if [ "$STATUS" = "Running" ]; then
  echo "PASS: web-app pod is Running"
  exit 0
else
  echo "FAIL: web-app pod status is $STATUS"
  exit 1
fi
