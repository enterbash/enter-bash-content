# Solution: Fix a Broken ConfigMap

## What the validator checks

- configmap.yaml or pod.yaml not found
- configmap.yaml does not pass validation
- pod.yaml does not pass validation
- DATABASE_PORT must be a string (wrap in quotes)
- MAX_CONNECTIONS must be a string (wrap in quotes)
- Pod configMapRef name must match ConfigMap name ($CM_NAME)

## Solution

ConfigMap values must be strings — wrap numbers in quotes.

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  DATABASE_HOST: "localhost"
  DATABASE_PORT: "5432"      # must be "5432" not 5432
  MAX_CONNECTIONS: "100"     # must be "100" not 100
  APP_ENV: "production"
```
