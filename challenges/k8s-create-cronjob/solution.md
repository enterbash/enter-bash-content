# Solution: Create a CronJob

## Solution

```yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-job
spec:
  schedule: "0 2 * * *"      # 2AM daily
  successfulJobsHistoryLimit: 3
  failedJobsHistoryLimit: 1
  jobTemplate:
    spec:
      template:
        spec:
          restartPolicy: OnFailure
          containers:
          - name: backup
            image: alpine
            command: ["sh", "-c", "echo 'backup complete'"]
```

## Why this works

CronJob schedule uses standard cron syntax. `successfulJobsHistoryLimit` and `failedJobsHistoryLimit` control how many completed Jobs are kept for debugging.
