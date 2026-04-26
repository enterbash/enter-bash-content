# Solution: Create and Configure a Namespace

## Solution

```yaml
apiVersion: v1
kind: Namespace
metadata:
  name: staging
  labels:
    env: staging
    team: backend
  annotations:
    description: "Staging environment for backend team"
```

```bash
kubectl apply --dry-run=server -f ~/namespace.yaml
```

## Why this works

Namespaces provide isolation between environments. Labels enable filtering and policy enforcement. Annotations store non-identifying metadata.
