# Solution: Create a CronJob

## What the validator checks

- ~/cronjob.yaml not found
- cronjob.yaml does not pass validation
- kind should be CronJob
- CronJob name should be log-cleanup
- schedule field is required
- restartPolicy should be OnFailure
- successfulJobsHistoryLimit should be set
- failedJobsHistoryLimit should be set

## Solution

```yaml
# ~/cronjob.yaml
apiVersion: batch/v1
kind: CronJob
metadata:
  name: backup-job
spec:
  schedule: "0 2 * * *"
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
