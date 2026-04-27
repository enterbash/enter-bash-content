#!/bin/bash
set -e

PASS=true
ERRORS=""

# 1. Check prometheus is running
if ! pgrep -x prometheus > /dev/null 2>&1; then
  ERRORS="${ERRORS}Prometheus is not running.\n"
  PASS=false
fi

# 2. Check node_exporter is running
if ! pgrep -f node_exporter > /dev/null 2>&1; then
  ERRORS="${ERRORS}node_exporter is not running.\n"
  PASS=false
fi

# 3. Check prometheus config has 'node' job
if ! grep -q 'job_name.*node' /etc/prometheus/prometheus.yml 2>/dev/null; then
  ERRORS="${ERRORS}Prometheus config missing 'node' scrape job.\n"
  PASS=false
fi

# 4. Check prometheus can scrape node_exporter
if $PASS; then
  sleep 2
  UP=$(curl -sf 'http://localhost:9090/api/v1/query?query=up{job="node"}' 2>/dev/null | jq -r '.data.result[0].value[1] // "0"')
  if [ "$UP" != "1" ]; then
    ERRORS="${ERRORS}Prometheus cannot scrape node_exporter (up{job=\"node\"} != 1). Wait a few seconds and try again.\n"
    PASS=false
  fi
fi

# 5. Check node_cpu_seconds_total metric exists
if $PASS; then
  COUNT=$(curl -sf 'http://localhost:9090/api/v1/query?query=node_cpu_seconds_total' 2>/dev/null | jq '.data.result | length')
  if [ "$COUNT" -lt 1 ] 2>/dev/null; then
    ERRORS="${ERRORS}node_cpu_seconds_total metric not found. Wait for first scrape.\n"
    PASS=false
  fi
fi

# 6. Check cpu_idle_query.txt exists with correct PromQL
if [ ! -f ~/cpu_idle_query.txt ]; then
  ERRORS="${ERRORS}~/cpu_idle_query.txt not found.\n"
  PASS=false
else
  QUERY=$(cat ~/cpu_idle_query.txt | tr -d '[:space:]')
  EXPECTED='avg(rate(node_cpu_seconds_total{mode="idle"}[1m]))*100'
  EXPECTED_CLEAN=$(echo "$EXPECTED" | tr -d '[:space:]')
  if [ "$QUERY" != "$EXPECTED_CLEAN" ]; then
    # Also accept 5m variant
    EXPECTED2='avg(rate(node_cpu_seconds_total{mode="idle"}[5m]))*100'
    EXPECTED2_CLEAN=$(echo "$EXPECTED2" | tr -d '[:space:]')
    if [ "$QUERY" != "$EXPECTED2_CLEAN" ]; then
      ERRORS="${ERRORS}PromQL in cpu_idle_query.txt doesn't match expected query.\n"
      PASS=false
    fi
  fi
fi

if $PASS; then
  echo "PASS: Prometheus monitoring is set up correctly!"
  exit 0
else
  echo -e "FAIL:\n${ERRORS}"
  exit 1
fi
