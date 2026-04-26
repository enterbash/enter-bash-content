# Solution: Fix a StatefulSet

## What the validator checks

- ~/statefulset.yaml not found
- statefulset.yaml does not pass validation
- should contain a StatefulSet
- StatefulSet requires serviceName field
- headless Service must have clusterIP: None
- replicas should be 3

## Solution

Two fixes needed: headless Service (`clusterIP: None`) and `serviceName` in StatefulSet.

```yaml
apiVersion: v1
kind: Service
metadata:
  name: postgres-headless
spec:
  clusterIP: None        # headless — required for StatefulSet DNS
  selector:
    app: postgres
  ports:
  - port: 5432
---
apiVersion: apps/v1
kind: StatefulSet
metadata:
  name: postgres
spec:
  serviceName: postgres-headless   # links to the headless service
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
