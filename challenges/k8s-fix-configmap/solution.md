# Solution: Fix a Broken ConfigMap

## Solution

ConfigMap values must be strings. Wrap numbers in quotes.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  DATABASE_HOST: "localhost"
  DATABASE_PORT: "5432"      # must be a string, not integer 5432
  MAX_CONNECTIONS: "100"     # must be a string, not integer 100
  APP_ENV: "production"
```

```yaml
# Pod referencing the ConfigMap
apiVersion: v1
kind: Pod
metadata:
  name: config-pod
spec:
  containers:
  - name: app
    image: alpine
    envFrom:
    - configMapRef:
        name: app-config    # must match ConfigMap name above
    command: ["sleep", "infinity"]
```

## Why this works

YAML integers are not strings. `DATABASE_PORT: 5432` is an integer; `DATABASE_PORT: "5432"` is a string. Kubernetes ConfigMap values must be strings.
