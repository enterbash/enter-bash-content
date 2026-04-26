# Solution: Fix Label Selectors

## Solution

The Deployment's `matchLabels` and Service's `selector` must both match the Pod template labels.

```yaml
# deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-server
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api-server      # must match template labels
  template:
    metadata:
      labels:
        app: api-server    # this is what Pods get
    spec:
      containers:
      - name: api
        image: nginx:alpine
```

```yaml
# service.yaml
apiVersion: v1
kind: Service
metadata:
  name: api-service
spec:
  selector:
    app: api-server        # must match Pod labels
  ports:
  - port: 80
    targetPort: 8080
```

## Why this works

Labels are the glue in Kubernetes. The Deployment uses `matchLabels` to find its Pods. The Service uses `selector` to find Pods to route traffic to. All three must be identical.
