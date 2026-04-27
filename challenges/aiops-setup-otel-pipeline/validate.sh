#!/bin/bash
set -e

PASS=true
ERRORS=""

# 1. Check otel-config.yaml exists
if [ ! -f ~/otel-config.yaml ]; then
  echo "FAIL: ~/otel-config.yaml not found."
  exit 1
fi

# 2. Check collector is running
if ! pgrep -f otelcol > /dev/null 2>&1; then
  ERRORS="${ERRORS}OTel Collector is not running.\n"
  PASS=false
fi

# 3. Check config has required sections
for SECTION in "receivers" "processors" "exporters" "service"; do
  if ! grep -q "$SECTION" ~/otel-config.yaml 2>/dev/null; then
    ERRORS="${ERRORS}Config missing '${SECTION}' section.\n"
    PASS=false
  fi
done

# 4. Check OTLP receiver configured
if ! grep -q "otlp" ~/otel-config.yaml 2>/dev/null; then
  ERRORS="${ERRORS}OTLP receiver not configured.\n"
  PASS=false
fi

# 5. Check batch processor
if ! grep -q "batch" ~/otel-config.yaml 2>/dev/null; then
  ERRORS="${ERRORS}Batch processor not configured.\n"
  PASS=false
fi

# 6. Check prometheus exporter
if ! grep -q "prometheus" ~/otel-config.yaml 2>/dev/null; then
  ERRORS="${ERRORS}Prometheus exporter not configured.\n"
  PASS=false
fi

# 7. Check port 8889 (prometheus exporter)
if $PASS; then
  if ! curl -sf http://localhost:8889/metrics > /dev/null 2>&1; then
    ERRORS="${ERRORS}Prometheus exporter not responding on port 8889.\n"
    PASS=false
  fi
fi

# 8. Check collector health endpoint
if $PASS; then
  if ! curl -sf http://localhost:13133/ > /dev/null 2>&1; then
    ERRORS="${ERRORS}Collector health endpoint not responding on port 13133.\n"
    PASS=false
  fi
fi

# 9. Check both gRPC and HTTP protocols
if ! grep -q "4317" ~/otel-config.yaml 2>/dev/null; then
  ERRORS="${ERRORS}gRPC endpoint (4317) not configured.\n"
  PASS=false
fi
if ! grep -q "4318" ~/otel-config.yaml 2>/dev/null; then
  ERRORS="${ERRORS}HTTP endpoint (4318) not configured.\n"
  PASS=false
fi

if $PASS; then
  echo "PASS: OpenTelemetry pipeline is running correctly!"
  exit 0
else
  echo -e "FAIL:\n${ERRORS}"
  exit 1
fi
