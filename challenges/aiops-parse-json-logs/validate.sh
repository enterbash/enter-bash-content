#!/bin/bash
set -e
PASS=true
ERRORS=""

# 1. errors_by_status.json
if [ ! -f ~/errors_by_status.json ]; then
  ERRORS="${ERRORS}~/errors_by_status.json not found.\n"; PASS=false
elif ! jq -e . ~/errors_by_status.json > /dev/null 2>&1; then
  ERRORS="${ERRORS}errors_by_status.json is not valid JSON.\n"; PASS=false
else
  COUNT=$(jq 'length' ~/errors_by_status.json)
  if [ "$COUNT" -lt 1 ] 2>/dev/null; then
    ERRORS="${ERRORS}errors_by_status.json has no entries.\n"; PASS=false
  fi
  # Check it has status and count fields
  HAS_FIELDS=$(jq '.[0] | has("status") and has("count")' ~/errors_by_status.json 2>/dev/null)
  if [ "$HAS_FIELDS" != "true" ]; then
    ERRORS="${ERRORS}errors_by_status.json entries need 'status' and 'count' fields.\n"; PASS=false
  fi
fi

# 2. slowest_requests.json
if [ ! -f ~/slowest_requests.json ]; then
  ERRORS="${ERRORS}~/slowest_requests.json not found.\n"; PASS=false
elif ! jq -e . ~/slowest_requests.json > /dev/null 2>&1; then
  ERRORS="${ERRORS}slowest_requests.json is not valid JSON.\n"; PASS=false
else
  COUNT=$(jq 'length' ~/slowest_requests.json)
  if [ "$COUNT" -ne 5 ] 2>/dev/null; then
    ERRORS="${ERRORS}slowest_requests.json should have exactly 5 entries, got ${COUNT}.\n"; PASS=false
  fi
  # Check sorted descending by latency
  FIRST=$(jq '.[0].latency_ms // 0' ~/slowest_requests.json)
  LAST=$(jq '.[-1].latency_ms // 0' ~/slowest_requests.json)
  if [ "$FIRST" -lt "$LAST" ] 2>/dev/null; then
    ERRORS="${ERRORS}slowest_requests.json should be sorted by latency descending.\n"; PASS=false
  fi
fi

# 3. worst_minute.txt
if [ ! -f ~/worst_minute.txt ]; then
  ERRORS="${ERRORS}~/worst_minute.txt not found.\n"; PASS=false
else
  MINUTE=$(cat ~/worst_minute.txt | tr -d '[:space:]')
  if [ -z "$MINUTE" ]; then
    ERRORS="${ERRORS}worst_minute.txt is empty.\n"; PASS=false
  elif ! echo "$MINUTE" | grep -qP '^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}$'; then
    ERRORS="${ERRORS}worst_minute.txt should contain a timestamp in YYYY-MM-DDTHH:MM format, got: ${MINUTE}\n"; PASS=false
  fi
fi

if $PASS; then
  echo "PASS: All log queries completed correctly!"
  exit 0
else
  echo -e "FAIL:\n${ERRORS}"
  exit 1
fi
