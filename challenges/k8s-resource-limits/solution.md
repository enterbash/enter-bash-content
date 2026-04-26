# Solution: Add Resource Limits

## Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: resource-pod
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

## Why this works

`requests` is what the scheduler uses to find a node with enough capacity. `limits` is the hard cap — exceeding memory causes OOMKill; exceeding CPU causes throttling. `100m` = 0.1 CPU cores.
