# Solution: Add Liveness and Readiness Probes

## Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: liveness-pod
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

## Why this works

`livenessProbe` restarts the container if it fails. `readinessProbe` removes the Pod from Service endpoints if it fails. `initialDelaySeconds` prevents false failures during startup.
