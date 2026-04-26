# Solution: Add Resource Limits

## What the validator checks

- ~/pod.yaml not found
- pod.yaml does not pass validation
- CPU request should be 100m
- Memory request should be 128Mi
- CPU limit should be 500m
- Memory limit should be 256Mi

## Solution

```yaml
spec:
  containers:
  - name: app
    image: nginx:alpine
    resources:
      requests:
        cpu: "100m"
        memory: "128Mi"
      limits:
        cpu: "500m"
        memory: "256Mi"
```

`100m` = 0.1 CPU cores. `requests` is used for scheduling; `limits` is the hard cap.
