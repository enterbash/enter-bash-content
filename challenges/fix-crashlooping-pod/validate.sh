#!/bin/bash

# Wait up to 30s for pod to reach Running or a terminal state
for i in $(seq 1 30); do
  STATUS=$(kubectl get pod web-app -o jsonpath='{.status.phase}' 2>/dev/null || echo "NotFound")
  case "$STATUS" in
    Running)
      echo "PASS: web-app pod is Running"
      exit 0
      ;;
    Failed|Unknown)
      echo "FAIL: web-app pod status is $STATUS"
      exit 1
      ;;
    NotFound)
      echo "FAIL: web-app pod not found — apply your fixed manifest first"
      exit 1
      ;;
  esac
  sleep 1
done

echo "FAIL: web-app pod did not reach Running within 30s (status: $STATUS)"
exit 1
