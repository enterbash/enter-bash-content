#!/bin/bash
set -e
PASS=true
ERRORS=""

if [ ! -f ~/correlation_results.json ]; then
  ERRORS="${ERRORS}Missing ~/correlation_results.json\n"; PASS=false
else
  # Check correlations field
  if ! jq -e 'has("correlations")' ~/correlation_results.json 2>/dev/null | grep -q true; then
    ERRORS="${ERRORS}Missing 'correlations' in correlation_results.json\n"; PASS=false
  else
    # Check at least one correlation has probable_cause
    HAS_CAUSE=$(jq '[.correlations[] | select(has("probable_cause"))] | length' ~/correlation_results.json 2>/dev/null)
    if [ "$HAS_CAUSE" -lt 1 ] 2>/dev/null; then
      ERRORS="${ERRORS}Correlations should have 'probable_cause' field.\n"; PASS=false
    fi
  fi

  # Check correlation_rate > 0.5
  if ! jq -e 'has("correlation_rate")' ~/correlation_results.json 2>/dev/null | grep -q true; then
    ERRORS="${ERRORS}Missing 'correlation_rate' in correlation_results.json\n"; PASS=false
  else
    RATE=$(jq '.correlation_rate // 0' ~/correlation_results.json)
    if [ "$(echo "$RATE > 0.5" | bc -l)" != "1" ] 2>/dev/null; then
      ERRORS="${ERRORS}correlation_rate should be > 0.5, got ${RATE}\n"; PASS=false
    fi
  fi
fi

if $PASS; then
  echo "PASS: Deploy-incident correlation analysis complete!"
  exit 0
else
  echo -e "FAIL:\n${ERRORS}"
  exit 1
fi
