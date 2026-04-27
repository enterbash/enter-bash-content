# Solution: Deploy a Kubernetes Microservice

## What the validator checks

- ~/microservice/app.yaml not found
- kubectl apply failed:
- ConfigMap web-api-config missing or APP_PORT not set — values must be strings
- Deployment should have 3 replicas, got <value>:-none}
- Deployment selector.matchLabels.app should be 'web-api', got '<value>'
- Pod template labels.app should be 'web-api', got '<value>'
- Service selector.app should be 'web-api', got '<value>'
- Container image should be nginx:alpine, got '<value>'
- containerPort should be 80, got '<value>'
- Service targetPort should be 80, got '<value>'
- Container missing resource requests (need cpu: 100m, memory: 128Mi)
- Container missing resource limits (need cpu: 500m, memory: 256Mi)
- Container missing livenessProbe — add httpGet on path / port 80
- Container missing readinessProbe — add httpGet on path / port 80
- Only <value>:-0}/3 pods are ready

## Solution

```bash
# Apply your manifest
kubectl apply --dry-run=server -f ~/manifest.yaml
```

