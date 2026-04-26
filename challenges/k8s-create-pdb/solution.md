# Solution: Create a PodDisruptionBudget

## Solution

```yaml
apiVersion: policy/v1
kind: PodDisruptionBudget
metadata:
  name: app-pdb
spec:
  minAvailable: 2           # or use maxUnavailable: 1
  selector:
    matchLabels:
      app: web-app
```

```yaml
# Deployment with enough replicas
apiVersion: apps/v1
kind: Deployment
metadata:
  name: web-app
spec:
  replicas: 4               # must be > minAvailable
  selector:
    matchLabels:
      app: web-app
  template:
    metadata:
      labels:
        app: web-app
    spec:
      containers:
      - name: app
        image: nginx:alpine
```

## Why this works

PDBs prevent too many Pods from being disrupted simultaneously during voluntary disruptions (node drains, rolling updates). `minAvailable: 2` ensures at least 2 Pods are always running.
