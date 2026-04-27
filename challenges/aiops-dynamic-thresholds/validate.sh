#!/bin/bash
set -e
PASS=true
ERRORS=""

if [ ! -f ~/threshold_results.json ]; then
  ERRORS="${ERRORS}Missing ~/threshold_results.json\n"; PASS=false
else
  # Check baseline exists with 24 hour entries
  BASELINE_LEN=$(jq '.baseline | length' ~/threshold_results.json 2>/dev/null)
  if [ "$BASELINE_LEN" != "24" ] 2>/dev/null; then
    ERRORS="${ERRORS}baseline should have 24 hourly entries, got ${BASELINE_LEN}\n"; PASS=false
  fi

  # Check baseline entries have mean and std
  if [ "$BASELINE_LEN" -gt 0 ] 2>/dev/null; then
    HAS_FIELDS=$(jq '.baseline["0"] | has("mean") and has("std")' ~/threshold_results.json 2>/dev/null || echo "false")
    if [ "$HAS_FIELDS" != "true" ]; then
      # Try array format
      HAS_FIELDS=$(jq '.baseline[0] | has("mean") and has("std")' ~/threshold_results.json 2>/dev/null || echo "false")
      if [ "$HAS_FIELDS" != "true" ]; then
        ERRORS="${ERRORS}Each baseline entry should have 'mean' and 'std' fields.\n"; PASS=false
      fi
    fi
  fi

  # Check anomalies detected
  if ! jq -e 'has("anomalies")' ~/threshold_results.json 2>/dev/null | grep -q true; then
    ERRORS="${ERRORS}Missing 'anomalies' field in threshold_results.json\n"; PASS=false
  else
    ANOMALY_COUNT=$(jq '.anomalies | length' ~/threshold_results.json 2>/dev/null)
    if [ "$ANOMALY_COUNT" -lt 1 ] 2>/dev/null; then
      ERRORS="${ERRORS}Should detect at least 1 anomaly, got ${ANOMALY_COUNT}\n"; PASS=false
    fi
  fi
fi

if $PASS; then
  echo "PASS: Dynamic thresholds computed and anomalies detected!"
  exit 0
else
  echo -e "FAIL:\n${ERRORS}"
  exit 1
fi
