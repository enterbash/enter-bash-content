# Solution: Configure Rolling Update Strategy

## Solution

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: rolling-app
spec:
  replicas: 4
  strategy:
    type: RollingUpdate
    rollingUpdate:
      maxSurge: 1
      maxUnavailable: 1
  minReadySeconds: 10
  selector:
    matchLabels:
      app: rolling-app
  template:
    metadata:
      labels:
        app: rolling-app
    spec:
      containers:
      - name: app
        image: nginx:1.25
```

## Why this works

`maxSurge: 1` allows one extra Pod during the update. `maxUnavailable: 1` allows one Pod to be down. `minReadySeconds: 10` waits 10s after a Pod is ready before continuing the rollout.
