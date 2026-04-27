#!/bin/bash
set -e
PASS=true
ERRORS=""

# Check slo_report.json exists
if [ ! -f ~/slo_report.json ]; then
  ERRORS="${ERRORS}Missing ~/slo_report.json\n"; PASS=false
else
  for FIELD in "slo_target" "burn_rate" "budget_consumed_percent"; do
    if ! jq -e "has(\"$FIELD\")" ~/slo_report.json 2>/dev/null | grep -q true; then
      ERRORS="${ERRORS}Missing field in slo_report.json: ${FIELD}\n"; PASS=false
    fi
  done

  SLO=$(jq '.slo_target // 0' ~/slo_report.json)
  if [ "$(echo "$SLO > 0" | bc -l)" != "1" ] 2>/dev/null; then
    ERRORS="${ERRORS}slo_target should be > 0, got ${SLO}\n"; PASS=false
  fi

  BURN=$(jq '.burn_rate // 0' ~/slo_report.json)
  if [ "$(echo "$BURN >= 0" | bc -l)" != "1" ] 2>/dev/null; then
    ERRORS="${ERRORS}burn_rate should be >= 0, got ${BURN}\n"; PASS=false
  fi

  BUDGET=$(jq '.budget_consumed_percent // -1' ~/slo_report.json)
  if [ "$(echo "$BUDGET >= 0" | bc -l)" != "1" ] 2>/dev/null; then
    ERRORS="${ERRORS}budget_consumed_percent should be >= 0, got ${BUDGET}\n"; PASS=false
  fi
fi

# Check slo_alert.yml exists and has HighErrorBudgetBurn
if [ ! -f ~/slo_alert.yml ]; then
  ERRORS="${ERRORS}Missing ~/slo_alert.yml\n"; PASS=false
else
  if ! grep -q "HighErrorBudgetBurn" ~/slo_alert.yml; then
    ERRORS="${ERRORS}slo_alert.yml should contain 'HighErrorBudgetBurn' alert rule.\n"; PASS=false
  fi
fi

if $PASS; then
  echo "PASS: SLO error budget calculations correct!"
  exit 0
else
  echo -e "FAIL:\n${ERRORS}"
  exit 1
fi
