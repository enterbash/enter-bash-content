# Solution: Create a Job

## What the validator checks

- ~/job.yaml not found
- job.yaml does not pass validation
- kind should be Job
- Job name should be data-processor
- image should be busybox
- backoffLimit should be set
- restartPolicy should be Never

## Solution

```yaml
# ~/job.yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: data-processor
spec:
  template:
    spec:
      restartPolicy: Never    # required for Jobs — not "Always"
      containers:
      - name: processor
        image: alpine
        command: ["sh", "-c", "echo 'processing' && sleep 5 && echo 'done'"]
```
