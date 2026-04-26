# Solution: Create a PriorityClass

## What the validator checks

- priorityclass.yaml or pod.yaml not found
- priorityclass.yaml does not pass validation
- pod.yaml does not pass validation
- kind should be PriorityClass
- PriorityClass name should be high-priority
- value should be 1000000
- globalDefault should be false
- Pod name should be critical-app
- Pod should reference high-priority PriorityClass

## Solution

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000000
globalDefault: false
description: "High priority workloads"
```
