# Solution: Fix Tolerations and Taints

## What the validator checks

- ~/pod.yaml not found
- pod.yaml does not pass validation
- dedicated toleration should use operator: Equal
- dedicated toleration should have value: gpu
- maintenance toleration should use operator: Exists
- maintenance toleration should have tolerationSeconds: 3600

## Solution

```yaml
spec:
  tolerations:
  - key: "dedicated"
    operator: "Equal"
    value: "gpu"
    effect: "NoSchedule"   # must match the taint exactly
```
