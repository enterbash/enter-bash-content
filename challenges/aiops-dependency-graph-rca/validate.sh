#!/bin/bash
set -e
PASS=true
ERRORS=""

if [ ! -f ~/rca_results.json ]; then
  ERRORS="${ERRORS}Missing ~/rca_results.json\n"; PASS=false
else
  # Check root_causes exists
  if ! jq -e 'has("root_causes")' ~/rca_results.json 2>/dev/null | grep -q true; then
    ERRORS="${ERRORS}Missing 'root_causes' in rca_results.json\n"; PASS=false
  else
    RC_COUNT=$(jq '.root_causes | length' ~/rca_results.json 2>/dev/null)
    if [ "$RC_COUNT" -lt 1 ] 2>/dev/null; then
      ERRORS="${ERRORS}root_causes should have at least 1 entry, got ${RC_COUNT}\n"; PASS=false
    fi

    # Check first root cause has required fields
    for FIELD in "service" "impact" "depth"; do
      HAS=$(jq ".root_causes[0] | has(\"$FIELD\")" ~/rca_results.json 2>/dev/null)
      if [ "$HAS" != "true" ]; then
        ERRORS="${ERRORS}Each root cause should have '${FIELD}' field.\n"; PASS=false
      fi
    done
  fi
fi

if $PASS; then
  echo "PASS: Dependency graph RCA analysis complete!"
  exit 0
else
  echo -e "FAIL:\n${ERRORS}"
  exit 1
fi
