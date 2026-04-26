# Solution: Create a ServiceAccount

## What the validator checks

- sa.yaml or rolebinding.yaml not found
- sa.yaml does not pass validation
- rolebinding.yaml does not pass validation
- kind should be ServiceAccount
- ServiceAccount name should be app-deployer
- should have label role: deployer
- RoleBinding name should be app-deployer-binding
- subject kind should be ServiceAccount
- roleRef name should be edit

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
