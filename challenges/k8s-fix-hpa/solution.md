# Solution: Fix HorizontalPodAutoscaler

## What the validator checks

- ~/hpa.yaml not found
- hpa.yaml does not pass validation
- kind should be HorizontalPodAutoscaler
- scaleTargetRef.kind should be Deployment
- scaleTargetRef.name should be web-app
- minReplicas should be 2
- maxReplicas should be 10

## Solution

```yaml
apiVersion: autoscaling/v2
kind: HorizontalPodAutoscaler
metadata:
  name: web-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deployment      # case-sensitive: "Deployment" not "deployment"
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
