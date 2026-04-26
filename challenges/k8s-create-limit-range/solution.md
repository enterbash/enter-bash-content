# Solution: Create a LimitRange

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
    min:
      cpu: "50m"
      memory: "64Mi"
```

## Why this works

LimitRange sets default resource requests/limits for containers that don't specify them. `default` is applied as the limit; `defaultRequest` as the request. `max`/`min` enforce boundaries.
