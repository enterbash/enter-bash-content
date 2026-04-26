# Solution: Fix Environment Variables

## What the validator checks

- ~/pod.yaml not found
- pod.yaml does not pass validation
- POD_NAME should use metadata.name, not metadata.labels
- POD_NAME should use fieldPath: metadata.name
- NODE_NAME should use spec.nodeName (capital N)
- NODE_NAME should use fieldPath: spec.nodeName

## Solution

```yaml
spec:
  containers:
  - name: app
    image: alpine
    env:
    - name: APP_ENV
      value: "production"
    - name: APP_PORT
      value: "8080"        # must be string "8080", not integer 8080
    command: ["sleep", "infinity"]
```
