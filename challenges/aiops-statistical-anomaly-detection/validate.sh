#!/bin/bash
set -e
PASS=true; ERRORS=""
if [ ! -f ~/detection_results.json ]; then echo "FAIL: ~/detection_results.json not found."; exit 1; fi
if ! jq -e . ~/detection_results.json > /dev/null 2>&1; then echo "FAIL: Not valid JSON."; exit 1; fi
for F in "zscore" "moving_avg" "both_methods"; do
  if ! jq -e "has(\"$F\")" ~/detection_results.json | grep -q true; then ERRORS="${ERRORS}Missing: ${F}\n"; PASS=false; fi
done
ZC=$(jq '.zscore.anomalies_found // 0' ~/detection_results.json)
MC=$(jq '.moving_avg.anomalies_found // 0' ~/detection_results.json)
BC=$(jq '.both_methods.count // 0' ~/detection_results.json)
if [ "$ZC" -lt 3 ] 2>/dev/null; then ERRORS="${ERRORS}Z-score found too few anomalies (${ZC}).\n"; PASS=false; fi
if [ "$MC" -lt 3 ] 2>/dev/null; then ERRORS="${ERRORS}Moving avg found too few anomalies (${MC}).\n"; PASS=false; fi
if [ "$BC" -lt 1 ] 2>/dev/null; then ERRORS="${ERRORS}both_methods should have at least 1 entry.\n"; PASS=false; fi
if $PASS; then echo "PASS: Both anomaly detection methods working!"; exit 0; else echo -e "FAIL:\n${ERRORS}"; exit 1; fi
