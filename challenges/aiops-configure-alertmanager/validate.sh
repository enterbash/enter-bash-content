#!/bin/bash
set -e

PASS=true
ERRORS=""

CONFIG="/etc/alertmanager/alertmanager.yml"

# 1. Check config exists
if [ ! -f "$CONFIG" ]; then
  echo "FAIL: ${CONFIG} not found."
  exit 1
fi

# 2. Validate config syntax
if ! amtool check-config "$CONFIG" > /dev/null 2>&1; then
  echo "FAIL: Invalid alertmanager config. Run: amtool check-config ${CONFIG}"
  exit 1
fi

# 3. Check Alertmanager is running
if ! curl -sf http://localhost:9093/-/healthy > /dev/null 2>&1; then
  ERRORS="${ERRORS}Alertmanager is not running on port 9093.\n"
  PASS=false
fi

# 4. Check config has required receivers
for RECV in "critical-alerts" "warning-alerts" "default"; do
  if ! grep -q "$RECV" "$CONFIG" 2>/dev/null; then
    ERRORS="${ERRORS}Missing receiver: ${RECV}\n"
    PASS=false
  fi
done

# 5. Check group_by includes alertname
if ! grep -q "alertname" "$CONFIG" 2>/dev/null; then
  ERRORS="${ERRORS}group_by should include 'alertname'.\n"
  PASS=false
fi

# 6. Check routing matchers for severity
if ! grep -q "severity" "$CONFIG" 2>/dev/null; then
  ERRORS="${ERRORS}No severity-based routing found.\n"
  PASS=false
fi

# 7. Check group_wait is set
if ! grep -q "group_wait" "$CONFIG" 2>/dev/null; then
  ERRORS="${ERRORS}group_wait not configured.\n"
  PASS=false
fi

if $PASS; then
  echo "PASS: Alertmanager routing configured correctly!"
  exit 0
else
  echo -e "FAIL:\n${ERRORS}"
  exit 1
fi
