#!/bin/bash
set -e
PASS=true
ERRORS=""

if [ ! -f ~/scoring_results.json ]; then
  ERRORS="${ERRORS}Missing ~/scoring_results.json\n"; PASS=false
else
  # Check training_accuracy
  if ! jq -e 'has("training_accuracy")' ~/scoring_results.json 2>/dev/null | grep -q true; then
    ERRORS="${ERRORS}Missing 'training_accuracy' in scoring_results.json\n"; PASS=false
  else
    ACC=$(jq '.training_accuracy // 0' ~/scoring_results.json)
    if [ "$(echo "$ACC > 0.6" | bc -l)" != "1" ] 2>/dev/null; then
      ERRORS="${ERRORS}training_accuracy should be > 0.6, got ${ACC}\n"; PASS=false
    fi
  fi

  # Check feature_importance
  if ! jq -e 'has("feature_importance")' ~/scoring_results.json 2>/dev/null | grep -q true; then
    ERRORS="${ERRORS}Missing 'feature_importance' in scoring_results.json\n"; PASS=false
  fi

  # Check scored_alerts has 50 entries
  if ! jq -e 'has("scored_alerts")' ~/scoring_results.json 2>/dev/null | grep -q true; then
    ERRORS="${ERRORS}Missing 'scored_alerts' in scoring_results.json\n"; PASS=false
  else
    SCORED=$(jq '.scored_alerts | length' ~/scoring_results.json 2>/dev/null)
    if [ "$SCORED" -ne 50 ] 2>/dev/null; then
      ERRORS="${ERRORS}scored_alerts should have 50 entries, got ${SCORED}\n"; PASS=false
    fi
  fi
fi

if $PASS; then
  echo "PASS: Alert scoring model trained and predictions generated!"
  exit 0
else
  echo -e "FAIL:\n${ERRORS}"
  exit 1
fi
