#!/bin/bash
set -e

PASS=true
ERRORS=""

# 1. Check dashboard.json exists
if [ ! -f ~/dashboard.json ]; then
  echo "FAIL: ~/dashboard.json not found."
  exit 1
fi

# 2. Check it's valid JSON
if ! jq -e . ~/dashboard.json > /dev/null 2>&1; then
  echo "FAIL: ~/dashboard.json is not valid JSON."
  exit 1
fi

# 3. Check title
TITLE=$(jq -r '.title // ""' ~/dashboard.json)
if [ -z "$TITLE" ]; then
  ERRORS="${ERRORS}Dashboard JSON missing 'title' field.\n"
  PASS=false
fi

# 4. Check panel count (need at least 4)
PANEL_COUNT=$(jq '.panels | length' ~/dashboard.json 2>/dev/null)
if [ "$PANEL_COUNT" -lt 4 ] 2>/dev/null; then
  ERRORS="${ERRORS}Need at least 4 panels, found ${PANEL_COUNT}.\n"
  PASS=false
fi

# 5. Check panels have PromQL targets
PANELS_WITH_EXPR=$(jq '[.panels[] | select(.targets[0].expr != null and .targets[0].expr != "")] | length' ~/dashboard.json 2>/dev/null)
if [ "$PANELS_WITH_EXPR" -lt 4 ] 2>/dev/null; then
  ERRORS="${ERRORS}Not all panels have PromQL expressions in targets.\n"
  PASS=false
fi

# 6. Check key metrics are referenced
for METRIC in "node_cpu_seconds_total" "node_memory" "node_filesystem" "node_network"; do
  if ! jq -r '.panels[].targets[].expr // ""' ~/dashboard.json 2>/dev/null | grep -q "$METRIC"; then
    ERRORS="${ERRORS}No panel references ${METRIC}.\n"
    PASS=false
  fi
done

# 7. Check dashboard was imported into Grafana
if curl -sf http://admin:admin@localhost:3000/api/health > /dev/null 2>&1; then
  DASH_COUNT=$(curl -sf 'http://admin:admin@localhost:3000/api/search?type=dash-db' 2>/dev/null | jq 'length')
  if [ "$DASH_COUNT" -lt 1 ] 2>/dev/null; then
    ERRORS="${ERRORS}Dashboard not imported into Grafana. Use the API to import it.\n"
    PASS=false
  fi
fi

if $PASS; then
  echo "PASS: Grafana dashboard created with all monitoring panels!"
  exit 0
else
  echo -e "FAIL:\n${ERRORS}"
  exit 1
fi
