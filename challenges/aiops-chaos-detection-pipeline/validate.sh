#!/bin/bash
set -e
PASS=true
ERRORS=""

if [ ! -f ~/detection_report.json ]; then
  ERRORS="${ERRORS}Missing ~/detection_report.json\n"; PASS=false
else
  # Check anomalies field
  if ! jq -e 'has("anomalies")' ~/detection_report.json 2>/dev/null | grep -q true; then
    ERRORS="${ERRORS}Missing 'anomalies' in detection_report.json\n"; PASS=false
  else
    ANOMALY_COUNT=$(jq '.anomalies | length' ~/detection_report.json 2>/dev/null)
    if [ "$ANOMALY_COUNT" -lt 1 ] 2>/dev/null; then
      ERRORS="${ERRORS}Should detect at least 1 anomaly, got ${ANOMALY_COUNT}\n"; PASS=false
    fi
  fi

  # Check probable_cause
  if ! jq -e 'has("probable_cause")' ~/detection_report.json 2>/dev/null | grep -q true; then
    ERRORS="${ERRORS}Missing 'probable_cause' in detection_report.json\n"; PASS=false
  else
    CAUSE=$(jq -r '.probable_cause // ""' ~/detection_report.json)
    if [ ${#CAUSE} -lt 5 ]; then
      ERRORS="${ERRORS}probable_cause should be a meaningful description\n"; PASS=false
    fi
  fi
fi

if $PASS; then
  echo "PASS: Chaos detection pipeline working!"
  exit 0
else
  echo -e "FAIL:\n${ERRORS}"
  exit 1
fi
