# Solution: Fix a Broken Service

## What the validator checks

- ~/service.yaml not found
- service.yaml does not pass validation
- apiVersion should be v1, got $API
- selector should match app: web-app
- port should be 80 (integer)
- targetPort should be 8080 (integer)

## Solution

```yaml
# ~/service.yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: web-app        # must match Pod labels
  ports:
  - port: 80            # integer, not string
    targetPort: 8080    # integer, not string
  type: ClusterIP
```

The validator checks: `apiVersion: v1`, `app: web-app` in selector, `port: 80`, `targetPort: 8080`.
