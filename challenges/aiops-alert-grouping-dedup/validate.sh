#!/bin/bash
set -e
PASS=true
ERRORS=""

# Check alertmanager.yml exists with inhibit_rules
if [ ! -f /etc/alertmanager/alertmanager.yml ]; then
  ERRORS="${ERRORS}Missing /etc/alertmanager/alertmanager.yml\n"; PASS=false
else
  if ! grep -q "inhibit_rules" /etc/alertmanager/alertmanager.yml; then
    ERRORS="${ERRORS}alertmanager.yml should contain 'inhibit_rules'.\n"; PASS=false
  fi
fi

# Check dedup_report.json
if [ ! -f ~/dedup_report.json ]; then
  ERRORS="${ERRORS}Missing ~/dedup_report.json\n"; PASS=false
else
  for FIELD in "original_count" "deduplicated_count" "reduction_percent"; do
    if ! jq -e "has(\"$FIELD\")" ~/dedup_report.json 2>/dev/null | grep -q true; then
      ERRORS="${ERRORS}Missing field in dedup_report.json: ${FIELD}\n"; PASS=false
    fi
  done

  REDUCTION=$(jq '.reduction_percent // 0' ~/dedup_report.json)
  if [ "$(echo "$REDUCTION > 80" | bc -l)" != "1" ] 2>/dev/null; then
    ERRORS="${ERRORS}reduction_percent should be > 80%, got ${REDUCTION}%\n"; PASS=false
  fi
fi

if $PASS; then
  echo "PASS: Alert grouping and deduplication configured correctly!"
  exit 0
else
  echo -e "FAIL:\n${ERRORS}"
  exit 1
fi
