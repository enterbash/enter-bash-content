#!/bin/bash
set -e

if [ ! -f ~/cronjob.yaml ]; then
  echo "FAIL: ~/cronjob.yaml not found"
  exit 1
fi

kubectl apply --dry-run=client -f ~/cronjob.yaml 2>/dev/null
if [ $? -ne 0 ]; then
  echo "FAIL: cronjob.yaml does not pass validation"
  exit 1
fi

if ! grep -q 'kind: CronJob' ~/cronjob.yaml; then
  echo "FAIL: kind should be CronJob"
  exit 1
fi

if ! grep -q 'name: log-cleanup' ~/cronjob.yaml; then
  echo "FAIL: CronJob name should be log-cleanup"
  exit 1
fi

if ! grep -q 'schedule:' ~/cronjob.yaml; then
  echo "FAIL: schedule field is required"
  exit 1
fi

if ! grep -q 'restartPolicy: OnFailure' ~/cronjob.yaml; then
  echo "FAIL: restartPolicy should be OnFailure"
  exit 1
fi

if ! grep -q 'successfulJobsHistoryLimit:' ~/cronjob.yaml; then
  echo "FAIL: successfulJobsHistoryLimit should be set"
  exit 1
fi

if ! grep -q 'failedJobsHistoryLimit:' ~/cronjob.yaml; then
  echo "FAIL: failedJobsHistoryLimit should be set"
  exit 1
fi

echo "PASS: CronJob manifest is valid and correct"
exit 0
