# Solution: Fix Container Port Configuration

## Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: port-pod
spec:
  containers:
  - name: web
    image: nginx:alpine
    ports:
    - containerPort: 80      # integer, not string "80"
---
apiVersion: v1
kind: Service
metadata:
  name: port-service
spec:
  selector:
    app: port-pod
  ports:
  - port: 80
    targetPort: 80           # must match containerPort
```

## Why this works

`containerPort` must be an integer. The Service `targetPort` must match the container's actual listening port.
