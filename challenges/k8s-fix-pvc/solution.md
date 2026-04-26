# Solution: Fix a PersistentVolumeClaim

## What the validator checks

- ~/pvc.yaml not found
- pvc.yaml does not pass validation
- accessMode should be ReadWriteOnce
- storage request should be 5Gi
- PVC resources.requests should not contain cpu

## Solution

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
spec:
  accessModes:
  - ReadWriteOnce
  resources:
    requests:
      storage: 5Gi    # PVCs request "storage", not "cpu" or "memory"
```
