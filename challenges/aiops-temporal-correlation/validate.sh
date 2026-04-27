#!/bin/bash
set -e
PASS=true
ERRORS=""

if [ ! -f ~/correlation_results.json ]; then
  ERRORS="${ERRORS}Missing ~/correlation_results.json\n"; PASS=false
else
  # Check clusters exist
  if ! jq -e 'has("clusters")' ~/correlation_results.json 2>/dev/null | grep -q true; then
    ERRORS="${ERRORS}Missing 'clusters' field in correlation_results.json\n"; PASS=false
  else
    # Each cluster should have 3+ events
    SMALL=$(jq '[.clusters[] | select((.events | length) < 3)] | length' ~/correlation_results.json 2>/dev/null)
    if [ "$SMALL" -gt 0 ] 2>/dev/null; then
      ERRORS="${ERRORS}Found ${SMALL} cluster(s) with fewer than 3 events.\n"; PASS=false
    fi
  fi

  # Check total_clusters >= 3
  if ! jq -e 'has("total_clusters")' ~/correlation_results.json 2>/dev/null | grep -q true; then
    ERRORS="${ERRORS}Missing 'total_clusters' field\n"; PASS=false
  else
    TOTAL=$(jq '.total_clusters // 0' ~/correlation_results.json)
    if [ "$TOTAL" -lt 3 ] 2>/dev/null; then
      ERRORS="${ERRORS}total_clusters should be >= 3, got ${TOTAL}\n"; PASS=false
    fi
  fi
fi

if $PASS; then
  echo "PASS: Temporal event correlation working correctly!"
  exit 0
else
  echo -e "FAIL:\n${ERRORS}"
  exit 1
fi
