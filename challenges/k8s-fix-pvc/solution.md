# Solution: Fix a PersistentVolumeClaim

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
      storage: 5Gi      # not "cpu" — PVCs request storage, not CPU
```

## Why this works

PVCs request `storage`, not `cpu` or `memory`. Those belong in Pod resource requests. `ReadWriteOnce` means one node can mount it read-write at a time.
