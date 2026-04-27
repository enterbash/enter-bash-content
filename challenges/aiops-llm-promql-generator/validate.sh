#!/bin/bash
set -e
PASS=true
ERRORS=""

if [ ! -f ~/generated_queries.json ]; then
  ERRORS="${ERRORS}Missing ~/generated_queries.json\n"; PASS=false
else
  # Check it has 5+ queries
  QUERY_COUNT=$(jq '. | length' ~/generated_queries.json 2>/dev/null || jq '.queries | length' ~/generated_queries.json 2>/dev/null || echo "0")
  if [ "$QUERY_COUNT" -lt 5 ] 2>/dev/null; then
    # Try nested structure
    QUERY_COUNT=$(jq '.queries | length' ~/generated_queries.json 2>/dev/null || echo "0")
    if [ "$QUERY_COUNT" -lt 5 ] 2>/dev/null; then
      ERRORS="${ERRORS}Should have 5+ generated queries, got ${QUERY_COUNT}\n"; PASS=false
    fi
  fi

  # Check entries have generated_promql field
  HAS_PROMQL=$(jq '(if type == "array" then .[0] else .queries[0] end) | has("generated_promql")' ~/generated_queries.json 2>/dev/null)
  if [ "$HAS_PROMQL" != "true" ]; then
    ERRORS="${ERRORS}Each query entry should have 'generated_promql' field.\n"; PASS=false
  fi

  # Check system_prompt exists somewhere in the file
  if ! jq -r 'tostring' ~/generated_queries.json 2>/dev/null | grep -qi "system_prompt"; then
    ERRORS="${ERRORS}Output should include 'system_prompt' used for generation.\n"; PASS=false
  fi
fi

if $PASS; then
  echo "PASS: LLM-powered PromQL generation working!"
  exit 0
else
  echo -e "FAIL:\n${ERRORS}"
  exit 1
fi
