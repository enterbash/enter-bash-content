#!/bin/bash
set -e
PASS=true
ERRORS=""

if [ ! -f ~/error_report.json ]; then
  echo "FAIL: ~/error_report.json not found. Run: python3 ~/extract_errors.py"
  exit 1
fi
if ! jq -e . ~/error_report.json > /dev/null 2>&1; then
  echo "FAIL: ~/error_report.json is not valid JSON."
  exit 1
fi

# Check required fields
for FIELD in "total_errors" "categories" "top_messages"; do
  if ! jq -e "has(\"$FIELD\")" ~/error_report.json | grep -q true; then
    ERRORS="${ERRORS}Missing field: ${FIELD}\n"; PASS=false
  fi
done

# Check total_errors is reasonable (should be > 50 given the log)
TOTAL=$(jq '.total_errors // 0' ~/error_report.json)
if [ "$TOTAL" -lt 20 ] 2>/dev/null; then
  ERRORS="${ERRORS}total_errors seems too low (${TOTAL}). Check your ERROR line detection.\n"; PASS=false
fi

# Check categories have count and percentage
CAT_COUNT=$(jq '.categories | keys | length' ~/error_report.json 2>/dev/null)
if [ "$CAT_COUNT" -lt 2 ] 2>/dev/null; then
  ERRORS="${ERRORS}Expected at least 2 error categories, got ${CAT_COUNT}.\n"; PASS=false
fi

# Check at least one category has count and percentage
FIRST_CAT=$(jq '.categories | keys[0]' ~/error_report.json 2>/dev/null)
if [ -n "$FIRST_CAT" ]; then
  HAS_COUNT=$(jq ".categories[$FIRST_CAT] | has(\"count\")" ~/error_report.json 2>/dev/null)
  HAS_PCT=$(jq ".categories[$FIRST_CAT] | has(\"percentage\")" ~/error_report.json 2>/dev/null)
  if [ "$HAS_COUNT" != "true" ] || [ "$HAS_PCT" != "true" ]; then
    ERRORS="${ERRORS}Each category needs 'count' and 'percentage' fields.\n"; PASS=false
  fi
fi

# Check top_messages has entries
MSG_COUNT=$(jq '.top_messages | length' ~/error_report.json 2>/dev/null)
if [ "$MSG_COUNT" -lt 1 ] 2>/dev/null; then
  ERRORS="${ERRORS}top_messages is empty.\n"; PASS=false
fi

if $PASS; then
  echo "PASS: Error patterns extracted correctly!"
  exit 0
else
  echo -e "FAIL:\n${ERRORS}"
  exit 1
fi
