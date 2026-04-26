# Solution: Create a LimitRange

## What the validator checks

- ~/limitrange.yaml not found
- limitrange.yaml does not pass validation
- kind should be LimitRange
- name should be default-limits
- type should be Container
- default limits should be set
- defaultRequest should be set
- max limits should be set
- min limits should be set

## Solution

```yaml
apiVersion: v1
kind: LimitRange
metadata:
  name: default-limits
spec:
  limits:
  - type: Container
    default:
      cpu: "500m"
      memory: "256Mi"
    defaultRequest:
      cpu: "100m"
      memory: "128Mi"
    max:
      cpu: "2"
      memory: "1Gi"
```
