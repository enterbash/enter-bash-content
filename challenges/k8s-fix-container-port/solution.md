# Solution: Fix Container Port Configuration

## What the validator checks

- pod.yaml or service.yaml not found
- pod.yaml does not pass validation
- service.yaml does not pass validation
- containerPort should be 3000
- Service port should be 80
- Service targetPort should be 3000
- Service selector should match Pod labels (app: node-app)

## Solution

```yaml
spec:
  containers:
  - name: web
    image: nginx:alpine
    ports:
    - containerPort: 80    # integer, not string "80"
```
