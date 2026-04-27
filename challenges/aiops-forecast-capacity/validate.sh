#!/bin/bash
set -e
PASS=true; ERRORS=""
if [ ! -f ~/forecast_result.json ]; then echo "FAIL: ~/forecast_result.json not found."; exit 1; fi
if ! jq -e . ~/forecast_result.json > /dev/null 2>&1; then echo "FAIL: Not valid JSON."; exit 1; fi
for F in "current_usage" "predicted_90_date" "days_until_90" "forecast_summary"; do
  if ! jq -e "has(\"$F\")" ~/forecast_result.json | grep -q true; then ERRORS="${ERRORS}Missing: ${F}\n"; PASS=false; fi
done
D90=$(jq -r '.predicted_90_date // ""' ~/forecast_result.json)
if [ -z "$D90" ] || [ "$D90" = "null" ]; then ERRORS="${ERRORS}predicted_90_date is empty.\n"; PASS=false; fi
DAYS=$(jq '.days_until_90 // 0' ~/forecast_result.json)
if [ "$DAYS" -lt 1 ] 2>/dev/null; then ERRORS="${ERRORS}days_until_90 should be positive.\n"; PASS=false; fi
FS=$(jq '.forecast_summary | length' ~/forecast_result.json 2>/dev/null)
if [ "$FS" -lt 7 ] 2>/dev/null; then ERRORS="${ERRORS}forecast_summary needs at least 7 entries.\n"; PASS=false; fi
HAS_PRED=$(jq '.forecast_summary[0] | has("predicted")' ~/forecast_result.json 2>/dev/null)
if [ "$HAS_PRED" != "true" ]; then ERRORS="${ERRORS}forecast_summary entries need 'predicted' field.\n"; PASS=false; fi
if $PASS; then echo "PASS: Capacity forecast complete!"; exit 0; else echo -e "FAIL:\n${ERRORS}"; exit 1; fi
