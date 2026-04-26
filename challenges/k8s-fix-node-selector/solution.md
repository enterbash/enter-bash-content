# Solution: Fix Node Selector and Affinity

## Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: node-selector-pod
spec:
  nodeSelector:
    disktype: ssd        # must match node label exactly
  containers:
  - name: app
    image: nginx:alpine
```

## Why this works

`nodeSelector` is a simple key-value match against node labels. The node must have the exact label for the Pod to be scheduled there. Use `kubectl get nodes --show-labels` to see available labels.
