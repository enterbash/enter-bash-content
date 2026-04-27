#!/bin/bash
set -e
PASS=true
ERRORS=""

# Check scaling_report.json
if [ ! -f ~/scaling_report.json ]; then
  ERRORS="${ERRORS}Missing ~/scaling_report.json\n"; PASS=false
else
  for FIELD in "anomalies_detected" "scaling_actions"; do
    if ! jq -e "has(\"$FIELD\")" ~/scaling_report.json 2>/dev/null | grep -q true; then
      ERRORS="${ERRORS}Missing '${FIELD}' in scaling_report.json\n"; PASS=false
    fi
  done

  ANOMALIES=$(jq '.anomalies_detected // 0' ~/scaling_report.json)
  if [ "$ANOMALIES" -lt 1 ] 2>/dev/null; then
    ERRORS="${ERRORS}anomalies_detected should be >= 1, got ${ANOMALIES}\n"; PASS=false
  fi

  ACTIONS=$(jq '.scaling_actions | length' ~/scaling_report.json 2>/dev/null)
  if [ "$ACTIONS" -lt 1 ] 2>/dev/null; then
    ERRORS="${ERRORS}scaling_actions should have at least 1 entry, got ${ACTIONS}\n"; PASS=false
  fi
fi

# Check scale_command.sh exists
if [ ! -f ~/scale_command.sh ]; then
  ERRORS="${ERRORS}Missing ~/scale_command.sh\n"; PASS=false
fi

if $PASS; then
  echo "PASS: Auto-scaling on anomaly detection configured!"
  exit 0
else
  echo -e "FAIL:\n${ERRORS}"
  exit 1
fi
