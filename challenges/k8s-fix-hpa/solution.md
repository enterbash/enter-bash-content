# Solution: Fix HorizontalPodAutoscaler

## Solution

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment      # must be "Deployment" not "deployment"
    name: web-app
  minReplicas: 2
  maxReplicas: 10
  metrics:
  - type: Resource
    resource:
      name: cpu
      target:
        type: Utilization
        averageUtilization: 70
```

## Why this works

`scaleTargetRef.kind` is case-sensitive — must be `Deployment`. `minReplicas: 2` and `maxReplicas: 10` are the required values. Use `autoscaling/v2` (not the deprecated `v1`).
