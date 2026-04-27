#!/bin/bash
set -e
PASS=true
ERRORS=""

if [ ! -f ~/log_summary.json ]; then
  ERRORS="${ERRORS}Missing ~/log_summary.json\n"; PASS=false
else
  for FIELD in "error_count" "key_events" "likely_root_cause" "prompt_template"; do
    if ! jq -e "has(\"$FIELD\")" ~/log_summary.json 2>/dev/null | grep -q true; then
      ERRORS="${ERRORS}Missing '${FIELD}' in log_summary.json\n"; PASS=false
    fi
  done

  ERROR_COUNT=$(jq '.error_count // 0' ~/log_summary.json)
  if [ "$ERROR_COUNT" -lt 1 ] 2>/dev/null; then
    ERRORS="${ERRORS}error_count should be >= 1, got ${ERROR_COUNT}\n"; PASS=false
  fi

  EVENTS_LEN=$(jq '.key_events | length' ~/log_summary.json 2>/dev/null)
  if [ "$EVENTS_LEN" -lt 1 ] 2>/dev/null; then
    ERRORS="${ERRORS}key_events should have at least 1 entry\n"; PASS=false
  fi

  ROOT_CAUSE=$(jq -r '.likely_root_cause // ""' ~/log_summary.json)
  if [ -z "$ROOT_CAUSE" ]; then
    ERRORS="${ERRORS}likely_root_cause should not be empty\n"; PASS=false
  fi
fi

if $PASS; then
  echo "PASS: LLM log summarization complete!"
  exit 0
else
  echo -e "FAIL:\n${ERRORS}"
  exit 1
fi
