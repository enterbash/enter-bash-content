# Solution: Configure Rolling Update Strategy

## What the validator checks

- ~/deployment.yaml not found
- deployment.yaml does not pass validation
- strategy type should be RollingUpdate
- maxSurge should be configured
- maxUnavailable should be configured
- minReadySeconds should be set

## Solution

```yaml
spec:
  replicas: 4
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  minReadySeconds: 10
```
