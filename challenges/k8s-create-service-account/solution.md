# Solution: Create a ServiceAccount

## Solution

```yaml
apiVersion: v1
kind: Service
metadata:
  name: web-service
spec:
  selector:
    app: web-app
  ports:
  - port: 80
    targetPort: 8080
  type: ClusterIP
```

## Why this works

`selector` must match the Pod labels exactly. `port` is what clients connect to; `targetPort` is the container port. Both must be integers (not strings).
