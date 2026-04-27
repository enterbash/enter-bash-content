#!/bin/bash
set -e

PASS=true
ERRORS=""

# 1. Check app.log exists
if [ ! -f ~/app.log ]; then
  echo "FAIL: ~/app.log not found. Run: python3 ~/app.py > ~/app.log 2>&1"
  exit 1
fi

# 2. Check at least 5 lines
LINE_COUNT=$(wc -l < ~/app.log)
if [ "$LINE_COUNT" -lt 5 ]; then
  ERRORS="${ERRORS}app.log has only ${LINE_COUNT} lines (need at least 5).\n"
  PASS=false
fi

# 3. Check every line is valid JSON with required fields
BAD_LINES=0
MISSING_FIELDS=0
while IFS= read -r line; do
  [ -z "$line" ] && continue
  if ! echo "$line" | jq -e . > /dev/null 2>&1; then
    BAD_LINES=$((BAD_LINES + 1))
    continue
  fi
  # Check required fields
  HAS_TS=$(echo "$line" | jq -r 'has("timestamp")')
  HAS_LVL=$(echo "$line" | jq -r 'has("level")')
  HAS_SVC=$(echo "$line" | jq -r 'has("service")')
  HAS_MSG=$(echo "$line" | jq -r 'has("message")')
  if [ "$HAS_TS" != "true" ] || [ "$HAS_LVL" != "true" ] || [ "$HAS_SVC" != "true" ] || [ "$HAS_MSG" != "true" ]; then
    MISSING_FIELDS=$((MISSING_FIELDS + 1))
  fi
done < ~/app.log

if [ "$BAD_LINES" -gt 0 ]; then
  ERRORS="${ERRORS}${BAD_LINES} lines are not valid JSON.\n"
  PASS=false
fi

if [ "$MISSING_FIELDS" -gt 0 ]; then
  ERRORS="${ERRORS}${MISSING_FIELDS} lines missing required fields (timestamp, level, service, message).\n"
  PASS=false
fi

# 4. Check service field is "web-api"
if $PASS; then
  SVC=$(head -1 ~/app.log | jq -r '.service // ""')
  if [ "$SVC" != "web-api" ]; then
    ERRORS="${ERRORS}service field should be 'web-api', got '${SVC}'.\n"
    PASS=false
  fi
fi

if $PASS; then
  echo "PASS: Structured logging implemented correctly!"
  exit 0
else
  echo -e "FAIL:\n${ERRORS}"
  exit 1
fi
