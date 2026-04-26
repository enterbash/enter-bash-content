# Solution: Add Liveness and Readiness Probes

## What the validator checks

- ~/pod.yaml not found
- pod.yaml does not pass validation
- livenessProbe is missing
- readinessProbe is missing
- probes should use httpGet
- initialDelaySeconds is missing
- periodSeconds is missing

## Solution

```yaml
spec:
  containers:
  - name: app
    image: nginx:alpine
    livenessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 10
      periodSeconds: 5
      failureThreshold: 3
    readinessProbe:
      httpGet:
        path: /
        port: 80
      initialDelaySeconds: 5
      periodSeconds: 3
```
