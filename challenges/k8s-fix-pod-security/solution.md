# Solution: Fix Pod Security Context

## Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: secure-pod
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

## Why this works

`runAsNonRoot: true` prevents running as root. `allowPrivilegeEscalation: false` prevents gaining more privileges. `capabilities: drop: ALL` removes all Linux capabilities. These are Pod Security Standards best practices.
