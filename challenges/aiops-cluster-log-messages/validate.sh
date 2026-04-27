#!/bin/bash
set -e
PASS=true
ERRORS=""

if [ ! -f ~/cluster_report.json ]; then
  echo "FAIL: ~/cluster_report.json not found."
  exit 1
fi
if ! jq -e . ~/cluster_report.json > /dev/null 2>&1; then
  echo "FAIL: ~/cluster_report.json is not valid JSON."
  exit 1
fi

# Check required fields
for FIELD in "total_lines" "total_clusters" "top_patterns"; do
  if ! jq -e "has(\"$FIELD\")" ~/cluster_report.json | grep -q true; then
    ERRORS="${ERRORS}Missing field: ${FIELD}\n"; PASS=false
  fi
done

TOTAL=$(jq '.total_lines // 0' ~/cluster_report.json)
if [ "$TOTAL" -lt 500 ] 2>/dev/null; then
  ERRORS="${ERRORS}total_lines should be ~1000, got ${TOTAL}.\n"; PASS=false
fi

CLUSTERS=$(jq '.total_clusters // 0' ~/cluster_report.json)
if [ "$CLUSTERS" -lt 5 ] 2>/dev/null; then
  ERRORS="${ERRORS}total_clusters seems too low (${CLUSTERS}). Expected 10+.\n"; PASS=false
fi

PATTERNS=$(jq '.top_patterns | length' ~/cluster_report.json 2>/dev/null)
if [ "$PATTERNS" -lt 5 ] 2>/dev/null; then
  ERRORS="${ERRORS}top_patterns should have at least 5 entries, got ${PATTERNS}.\n"; PASS=false
fi

# Check each pattern has template and count
FIRST_HAS=$(jq '.top_patterns[0] | has("template") and has("count")' ~/cluster_report.json 2>/dev/null)
if [ "$FIRST_HAS" != "true" ]; then
  ERRORS="${ERRORS}Each pattern needs 'template' and 'count' fields.\n"; PASS=false
fi

# Check sorted descending
FIRST_COUNT=$(jq '.top_patterns[0].count // 0' ~/cluster_report.json)
LAST_COUNT=$(jq '.top_patterns[-1].count // 0' ~/cluster_report.json)
if [ "$FIRST_COUNT" -lt "$LAST_COUNT" ] 2>/dev/null; then
  ERRORS="${ERRORS}top_patterns should be sorted by count descending.\n"; PASS=false
fi

if $PASS; then
  echo "PASS: Log clustering complete!"
  exit 0
else
  echo -e "FAIL:\n${ERRORS}"
  exit 1
fi
