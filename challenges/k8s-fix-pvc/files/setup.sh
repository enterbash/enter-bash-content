#!/bin/bash
# Create broken PVC manifest
cat > ~/pvc.yaml <<'EOF'
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: data-pvc
spec:
  accessModes:
    - ReadWriteMany
  storageClassName: standard
  resources:
    requests:
      storage: 5Gi
      cpu: 100m
EOF
