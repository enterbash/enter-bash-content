# Solution: Fix Label Selectors

## What the validator checks

- deployment.yaml or service.yaml not found
- deployment.yaml does not pass validation
- service.yaml does not pass validation
- Deployment matchLabels should use app: api-server
- Service selector should use app: api-server

## Solution

The Deployment `matchLabels`, Pod template labels, and Service `selector` must all match.

```yaml
# deployment.yaml
spec:
  selector:
    matchLabels:
      app: api-server      # must match template labels
  template:
    metadata:
      labels:
        app: api-server    # Pods get this label
```

```yaml
# service.yaml
spec:
  selector:
    app: api-server        # must match Pod labels
```
