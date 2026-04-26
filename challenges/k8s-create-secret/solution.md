# Solution: Create a Secret

## Solution

```yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  DB_USER: YWRtaW4=        # base64("admin")
  DB_PASS: c3VwZXJzZWNyZXQ=  # base64("supersecret")
```

```yaml
# Pod using the secret
apiVersion: v1
kind: Pod
metadata:
  name: secret-pod
spec:
  containers:
  - name: app
    image: alpine
    env:
    - name: DB_USER
      valueFrom:
        secretKeyRef:
          name: app-secret
          key: DB_USER
    - name: DB_PASS
      valueFrom:
        secretKeyRef:
          name: app-secret
          key: DB_PASS
    command: ["sleep", "infinity"]
```

```bash
# Encode values
echo -n "admin" | base64
echo -n "supersecret" | base64
```

## Why this works

Secret values must be base64-encoded in the YAML. `secretKeyRef` injects them as environment variables.
