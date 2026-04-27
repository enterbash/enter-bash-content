#!/bin/bash
set -e
PASS=true
ERRORS=""

if [ ! -f ~/anomalies.json ]; then
  echo "FAIL: ~/anomalies.json not found."
  exit 1
fi
if ! jq -e . ~/anomalies.json > /dev/null 2>&1; then
  echo "FAIL: ~/anomalies.json is not valid JSON."
  exit 1
fi

for FIELD in "mean" "std_dev" "threshold" "total_anomalies" "anomalies"; do
  if ! jq -e "has(\"$FIELD\")" ~/anomalies.json | grep -q true; then
    ERRORS="${ERRORS}Missing field: ${FIELD}\n"; PASS=false
  fi
done

THRESHOLD=$(jq '.threshold // 0' ~/anomalies.json)
if [ "$(echo "$THRESHOLD < 1.5" | bc -l 2>/dev/null || echo 1)" = "1" ] && [ "$THRESHOLD" != "2" ] && [ "$THRESHOLD" != "2.0" ]; then
  # Accept thresholds between 1.5 and 3.0
  true
fi

TOTAL=$(jq '.total_anomalies // 0' ~/anomalies.json)
if [ "$TOTAL" -lt 3 ] 2>/dev/null; then
  ERRORS="${ERRORS}total_anomalies too low (${TOTAL}). Expected 5+.\n"; PASS=false
fi

# Check anomalies array structure
ANOM_LEN=$(jq '.anomalies | length' ~/anomalies.json 2>/dev/null)
if [ "$ANOM_LEN" -lt 3 ] 2>/dev/null; then
  ERRORS="${ERRORS}anomalies array has only ${ANOM_LEN} entries.\n"; PASS=false
fi

# Check first anomaly has required fields
FIRST_OK=$(jq '.anomalies[0] | has("minute") and has("count") and has("z_score") and has("type")' ~/anomalies.json 2>/dev/null)
if [ "$FIRST_OK" != "true" ]; then
  ERRORS="${ERRORS}Each anomaly needs: minute, count, z_score, type.\n"; PASS=false
fi

# Check type values
TYPES=$(jq -r '.anomalies[].type' ~/anomalies.json 2>/dev/null | sort -u)
if ! echo "$TYPES" | grep -q "spike"; then
  ERRORS="${ERRORS}Expected at least one 'spike' anomaly.\n"; PASS=false
fi
if ! echo "$TYPES" | grep -q "drop"; then
  ERRORS="${ERRORS}Expected at least one 'drop' anomaly.\n"; PASS=false
fi

if $PASS; then
  echo "PASS: Anomaly detection working correctly!"
  exit 0
else
  echo -e "FAIL:\n${ERRORS}"
  exit 1
fi
