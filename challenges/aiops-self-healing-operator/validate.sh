#!/bin/bash
set -e
PASS=true
ERRORS=""

# Check healer.py exists
if [ ! -f ~/healer.py ]; then
  ERRORS="${ERRORS}Missing ~/healer.py\n"; PASS=false
fi

# Check healer_log.json exists
if [ ! -f ~/healer_log.json ]; then
  ERRORS="${ERRORS}Missing ~/healer_log.json\n"; PASS=false
else
  # Should be valid JSON array or object
  if ! jq empty ~/healer_log.json 2>/dev/null; then
    ERRORS="${ERRORS}~/healer_log.json is not valid JSON\n"; PASS=false
  fi
fi

# Check healer-deployment.yaml exists with ServiceAccount
if [ ! -f ~/healer-deployment.yaml ]; then
  ERRORS="${ERRORS}Missing ~/healer-deployment.yaml\n"; PASS=false
else
  if ! grep -q "ServiceAccount" ~/healer-deployment.yaml; then
    ERRORS="${ERRORS}healer-deployment.yaml should reference a ServiceAccount\n"; PASS=false
  fi
  if ! grep -q "kind:" ~/healer-deployment.yaml; then
    ERRORS="${ERRORS}healer-deployment.yaml should have 'kind:' resource definitions\n"; PASS=false
  fi
fi

if $PASS; then
  echo "PASS: Self-healing operator implemented!"
  exit 0
else
  echo -e "FAIL:\n${ERRORS}"
  exit 1
fi
