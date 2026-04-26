# Solution: Create a Deployment

## What the validator checks

- ~/deployment.yaml not found
- deployment.yaml does not pass validation
- kind should be Deployment
- Deployment name should be nginx-deploy
- replicas should be 3
- image should be nginx:1.25
- containerPort should be 80
- labels should include app: nginx

## Solution

```yaml
# ~/deployment.yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: nginx-deploy
  labels:
    app: nginx
spec:
  replicas: 3
  selector:
    matchLabels:
      app: nginx
  template:
    metadata:
      labels:
        app: nginx
    spec:
      containers:
      - name: nginx
        image: nginx:1.25
        ports:
        - containerPort: 80
```

```bash
kubectl apply --dry-run=server -f ~/deployment.yaml
```

`spec.selector.matchLabels` must match `spec.template.metadata.labels` exactly.
