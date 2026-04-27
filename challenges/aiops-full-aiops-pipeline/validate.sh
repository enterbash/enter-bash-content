#!/bin/bash
set -e
PASS=true
ERRORS=""

if [ ! -f ~/pipeline_report.json ]; then
  ERRORS="${ERRORS}Missing ~/pipeline_report.json\n"; PASS=false
else
  # Check pipeline_stages exists with 5 stages
  if ! jq -e 'has("pipeline_stages")' ~/pipeline_report.json 2>/dev/null | grep -q true; then
    ERRORS="${ERRORS}Missing 'pipeline_stages' in pipeline_report.json\n"; PASS=false
  else
    STAGES=$(jq '.pipeline_stages | length' ~/pipeline_report.json 2>/dev/null)
    if [ "$STAGES" -lt 5 ] 2>/dev/null; then
      ERRORS="${ERRORS}pipeline_stages should have 5 stages, got ${STAGES}\n"; PASS=false
    fi

    # Check each stage has a result
    MISSING_RESULTS=$(jq '[.pipeline_stages[] | select(.result == null or .result == "")] | length' ~/pipeline_report.json 2>/dev/null || echo "0")
    if [ "$MISSING_RESULTS" -gt 0 ] 2>/dev/null; then
      ERRORS="${ERRORS}${MISSING_RESULTS} pipeline stage(s) missing results.\n"; PASS=false
    fi
  fi
fi

if $PASS; then
  echo "PASS: Full AIOps pipeline complete! All 5 stages executed successfully."
  exit 0
else
  echo -e "FAIL:\n${ERRORS}"
  exit 1
fi
