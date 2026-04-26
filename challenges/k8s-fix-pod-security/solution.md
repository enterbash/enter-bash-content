# Solution: Fix Pod Security Context

## What the validator checks

- ~/pod.yaml not found
- pod.yaml does not pass validation
- privileged must be false
- runAsUser must not be 0 (root)
- runAsUser should be 1000
- runAsNonRoot should be true
- readOnlyRootFilesystem should be true
- allowPrivilegeEscalation should be false

## Solution

```yaml
spec:
  securityContext:
    runAsNonRoot: true
    runAsUser: 1000
  containers:
  - name: app
    image: nginx:alpine
    securityContext:
      allowPrivilegeEscalation: false
      readOnlyRootFilesystem: true
      capabilities:
        drop:
        - ALL
```
