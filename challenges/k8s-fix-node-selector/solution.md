# Solution: Fix Node Selector and Affinity

## What the validator checks

- ~/pod.yaml not found
- pod.yaml does not pass validation
- nodeSelector is missing
- affinity is missing
- nodeAffinity is missing

## Solution

```yaml
spec:
  nodeSelector:
    disktype: ssd    # must match node label exactly
```

Check available node labels: `kubectl get nodes --show-labels`
