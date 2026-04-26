# Solution: Create and Configure a Namespace

## What the validator checks

- ~/namespace.yaml not found
- namespace.yaml does not pass validation
- kind should be Namespace
- name should be staging
- should have label env: staging
- should have label team: backend
- should have description annotation

## Solution

```yaml
# ~/namespace.yaml
apiVersion: v1
kind: Namespace
metadata:
  name: staging
  labels:
    env: staging
```

```bash
kubectl apply --dry-run=server -f ~/namespace.yaml
```
