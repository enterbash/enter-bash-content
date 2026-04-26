# Solution: Create a Secret

## What the validator checks

- secret.yaml or pod.yaml not found
- secret.yaml does not pass validation
- pod.yaml does not pass validation
- kind should be Secret
- Secret name should be db-credentials
- Secret should have username key
- Secret should have password key
- Pod should reference db-credentials secret
- Pod should have DB_USER env var
- Pod should have DB_PASS env var

## Solution

```yaml
# ~/secret.yaml
apiVersion: v1
kind: Secret
metadata:
  name: app-secret
type: Opaque
data:
  DB_USER: YWRtaW4=        # base64("admin")
  DB_PASS: c3VwZXJzZWNyZXQ=  # base64("supersecret")
```

```bash
# Encode values
echo -n "admin" | base64
echo -n "supersecret" | base64
```
