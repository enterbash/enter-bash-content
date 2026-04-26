# Solution: Create a ResourceQuota

## What the validator checks

- ~/quota.yaml not found
- quota.yaml does not pass validation
- kind should be ResourceQuota
- name should be team-quota
- should have pods quota
- should have requests.cpu quota
- should have requests.memory quota
- should have limits.cpu quota
- should have limits.memory quota
- should have services quota

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
```
