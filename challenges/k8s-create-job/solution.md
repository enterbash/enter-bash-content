# Solution: Create a Job

## Solution

```yaml
apiVersion: batch/v1
kind: Job
metadata:
  name: data-processor
spec:
  completions: 1
  parallelism: 1
  template:
    spec:
      restartPolicy: Never    # required for Jobs (not Always)
      containers:
      - name: processor
        image: alpine
        command: ["sh", "-c", "echo 'processing data' && sleep 5 && echo 'done'"]
```

## Why this works

Jobs run to completion (unlike Deployments which run forever). `restartPolicy: Never` or `OnFailure` are the only valid values for Jobs. `completions` sets how many successful runs are needed.
