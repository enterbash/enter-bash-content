#!/bin/bash
set -e
PASS=true; ERRORS=""
if [ ! -f ~/if_results.json ]; then echo "FAIL: ~/if_results.json not found."; exit 1; fi
if ! jq -e . ~/if_results.json > /dev/null 2>&1; then echo "FAIL: Not valid JSON."; exit 1; fi
for F in "model" "contamination" "total_points" "anomalies_detected" "anomalies"; do
  if ! jq -e "has(\"$F\")" ~/if_results.json | grep -q true; then ERRORS="${ERRORS}Missing: ${F}\n"; PASS=false; fi
done
AD=$(jq '.anomalies_detected // 0' ~/if_results.json)
if [ "$AD" -lt 20 ] 2>/dev/null; then ERRORS="${ERRORS}Too few anomalies (${AD}). With contamination=0.05 on 1440 points, expect ~72.\n"; PASS=false; fi
AL=$(jq '.anomalies | length' ~/if_results.json 2>/dev/null)
if [ "$AL" -lt 20 ] 2>/dev/null; then ERRORS="${ERRORS}anomalies array has only ${AL} entries.\n"; PASS=false; fi
HAS_SCORE=$(jq '.anomalies[0] | has("anomaly_score")' ~/if_results.json 2>/dev/null)
if [ "$HAS_SCORE" != "true" ]; then ERRORS="${ERRORS}Each anomaly needs 'anomaly_score' field.\n"; PASS=false; fi
if $PASS; then echo "PASS: Isolation Forest anomaly detection working!"; exit 0; else echo -e "FAIL:\n${ERRORS}"; exit 1; fi
