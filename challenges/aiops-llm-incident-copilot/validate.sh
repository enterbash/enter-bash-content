#!/bin/bash
set -e
PASS=true
ERRORS=""

if [ ! -f ~/diagnosis.json ]; then
  ERRORS="${ERRORS}Missing ~/diagnosis.json\n"; PASS=false
else
  # Check tools_called has 2+ entries
  if ! jq -e 'has("tools_called")' ~/diagnosis.json 2>/dev/null | grep -q true; then
    ERRORS="${ERRORS}Missing 'tools_called' in diagnosis.json\n"; PASS=false
  else
    TOOLS=$(jq '.tools_called | length' ~/diagnosis.json 2>/dev/null)
    if [ "$TOOLS" -lt 2 ] 2>/dev/null; then
      ERRORS="${ERRORS}tools_called should have 2+ entries, got ${TOOLS}\n"; PASS=false
    fi
  fi

  # Check diagnosis field
  if ! jq -e 'has("diagnosis")' ~/diagnosis.json 2>/dev/null | grep -q true; then
    ERRORS="${ERRORS}Missing 'diagnosis' in diagnosis.json\n"; PASS=false
  else
    DIAG=$(jq -r '.diagnosis // ""' ~/diagnosis.json)
    if [ ${#DIAG} -lt 20 ]; then
      ERRORS="${ERRORS}diagnosis should be a meaningful description (got ${#DIAG} chars)\n"; PASS=false
    fi
  fi

  # Check evidence
  if ! jq -e 'has("evidence")' ~/diagnosis.json 2>/dev/null | grep -q true; then
    ERRORS="${ERRORS}Missing 'evidence' in diagnosis.json\n"; PASS=false
  else
    EV_COUNT=$(jq '.evidence | length' ~/diagnosis.json 2>/dev/null)
    if [ "$EV_COUNT" -lt 1 ] 2>/dev/null; then
      ERRORS="${ERRORS}evidence should have at least 1 entry\n"; PASS=false
    fi
  fi

  # Check recommended_actions
  if ! jq -e 'has("recommended_actions")' ~/diagnosis.json 2>/dev/null | grep -q true; then
    ERRORS="${ERRORS}Missing 'recommended_actions' in diagnosis.json\n"; PASS=false
  else
    ACTIONS=$(jq '.recommended_actions | length' ~/diagnosis.json 2>/dev/null)
    if [ "$ACTIONS" -lt 1 ] 2>/dev/null; then
      ERRORS="${ERRORS}recommended_actions should have at least 1 entry\n"; PASS=false
    fi
  fi
fi

if $PASS; then
  echo "PASS: LLM incident copilot working correctly!"
  exit 0
else
  echo -e "FAIL:\n${ERRORS}"
  exit 1
fi
