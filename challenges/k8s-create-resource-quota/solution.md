# Solution: Create a ResourceQuota

## Solution

```yaml
apiVersion: v1
kind: ResourceQuota
metadata:
  name: namespace-quota
spec:
  hard:
    requests.cpu: "4"
    requests.memory: "4Gi"
    limits.cpu: "8"
    limits.memory: "8Gi"
    pods: "20"
    services: "10"
    persistentvolumeclaims: "5"
```

## Why this works

ResourceQuota limits total resource consumption in a namespace. `requests.*` limits what can be requested; `limits.*` limits the hard caps. `pods`, `services` limit object counts.
