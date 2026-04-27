#!/bin/bash
set -e
PASS=true
ERRORS=""

# Check auto_restart.sh exists and is executable
if [ ! -f ~/auto_restart.sh ]; then
  ERRORS="${ERRORS}Missing ~/auto_restart.sh\n"; PASS=false
elif [ ! -x ~/auto_restart.sh ]; then
  ERRORS="${ERRORS}~/auto_restart.sh is not executable (chmod +x)\n"; PASS=false
fi

# Check restart-cronjob.yaml exists and is valid
if [ ! -f ~/restart-cronjob.yaml ]; then
  ERRORS="${ERRORS}Missing ~/restart-cronjob.yaml\n"; PASS=false
else
  # Check it's valid YAML with kind: CronJob
  if ! grep -q "kind: CronJob" ~/restart-cronjob.yaml; then
    ERRORS="${ERRORS}restart-cronjob.yaml should have 'kind: CronJob'\n"; PASS=false
  fi
  if ! grep -q "schedule:" ~/restart-cronjob.yaml; then
    ERRORS="${ERRORS}restart-cronjob.yaml should have a 'schedule:' field\n"; PASS=false
  fi
fi

if $PASS; then
  echo "PASS: Auto-restart pod remediation configured!"
  exit 0
else
  echo -e "FAIL:\n${ERRORS}"
  exit 1
fi
