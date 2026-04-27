#!/bin/bash
set -e
PASS=true
ERRORS=""

# Check diagnose.sh exists and is executable
if [ ! -f ~/diagnose.sh ]; then
  ERRORS="${ERRORS}Missing ~/diagnose.sh\n"; PASS=false
elif [ ! -x ~/diagnose.sh ]; then
  ERRORS="${ERRORS}~/diagnose.sh is not executable (chmod +x)\n"; PASS=false
fi

# Check diagnostic_report.txt exists with required sections
if [ ! -f ~/diagnostic_report.txt ]; then
  ERRORS="${ERRORS}Missing ~/diagnostic_report.txt\n"; PASS=false
else
  for SECTION in "POD STATUS" "POD LOGS" "EVENTS"; do
    if ! grep -qi "$SECTION" ~/diagnostic_report.txt; then
      ERRORS="${ERRORS}diagnostic_report.txt missing section: ${SECTION}\n"; PASS=false
    fi
  done

  LINES=$(wc -l < ~/diagnostic_report.txt)
  if [ "$LINES" -lt 5 ] 2>/dev/null; then
    ERRORS="${ERRORS}diagnostic_report.txt seems too short (${LINES} lines)\n"; PASS=false
  fi
fi

if $PASS; then
  echo "PASS: Auto-diagnostics script working correctly!"
  exit 0
else
  echo -e "FAIL:\n${ERRORS}"
  exit 1
fi
