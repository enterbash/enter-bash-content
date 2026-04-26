# Solution: Fix Tolerations and Taints

## Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: toleration-pod
spec:
  tolerations:
  - key: "dedicated"
    operator: "Equal"
    value: "gpu"
    effect: "NoSchedule"
  containers:
  - name: app
    image: nginx:alpine
```

## Why this works

Tolerations must match the taint exactly: same `key`, `value`, and `effect`. `operator: Equal` requires a value match. `operator: Exists` matches any value for that key.
