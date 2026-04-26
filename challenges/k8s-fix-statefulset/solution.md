# Solution: Fix a StatefulSet

## Solution

Two fixes needed: add `clusterIP: None` to the Service (headless) and add `serviceName` to the StatefulSet.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres-headless
spec:
  clusterIP: None        # headless service — required for StatefulSet DNS
  selector:
    app: postgres
  ports:
  - port: 5432
```

```yaml
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres-headless   # must reference the headless service
  replicas: 3
  selector:
    matchLabels:
      app: postgres
  template:
    metadata:
      labels:
        app: postgres
    spec:
      containers:
      - name: postgres
        image: postgres:15
```

## Why this works

StatefulSets require a headless Service (`clusterIP: None`) for stable DNS names (`pod-0.service.namespace.svc.cluster.local`). The `serviceName` field links them.
