#!/bin/bash
set -e
PASS=true; ERRORS=""
if [ ! -f ~/decomposition.json ]; then echo "FAIL: ~/decomposition.json not found."; exit 1; fi
if ! jq -e . ~/decomposition.json > /dev/null 2>&1; then echo "FAIL: Not valid JSON."; exit 1; fi
for F in "period" "trend_range" "seasonal_amplitude" "residual_std" "anomalies" "total_anomalies"; do
  if ! jq -e "has(\"$F\")" ~/decomposition.json | grep -q true; then ERRORS="${ERRORS}Missing: ${F}\n"; PASS=false; fi
done
P=$(jq '.period // 0' ~/decomposition.json)
if [ "$P" != "24" ]; then ERRORS="${ERRORS}period should be 24, got ${P}.\n"; PASS=false; fi
TA=$(jq '.total_anomalies // 0' ~/decomposition.json)
if [ "$TA" -lt 2 ] 2>/dev/null; then ERRORS="${ERRORS}Expected at least 2 anomalies, got ${TA}.\n"; PASS=false; fi
SA=$(jq '.seasonal_amplitude // 0' ~/decomposition.json)
if [ "$(echo "$SA < 100" | bc -l 2>/dev/null || echo 0)" = "1" ]; then ERRORS="${ERRORS}seasonal_amplitude seems too low (${SA}).\n"; PASS=false; fi
if $PASS; then echo "PASS: Seasonal decomposition complete!"; exit 0; else echo -e "FAIL:\n${ERRORS}"; exit 1; fi
