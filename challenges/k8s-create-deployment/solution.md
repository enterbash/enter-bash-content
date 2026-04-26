# Solution: Create a Deployment

## Solution

```yaml
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

## Why this works

A Deployment needs `spec.selector.matchLabels` to match `spec.template.metadata.labels` — this is how it knows which Pods belong to it. The `replicas: 3` creates 3 identical Pods.
