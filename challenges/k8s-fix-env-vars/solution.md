# Solution: Fix Environment Variables

## Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: env-pod
spec:
  containers:
  - name: app
    image: alpine
    env:
    - name: APP_ENV
      value: "production"
    - name: APP_PORT
      value: "8080"        # must be string, not integer
    - name: DB_HOST
      value: "localhost"
    command: ["sleep", "infinity"]
```

## Why this works

Environment variable values in Kubernetes must be strings. `value: 8080` (integer) causes a validation error — use `value: "8080"` (quoted string).
