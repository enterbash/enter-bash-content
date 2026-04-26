#!/bin/bash
# Create broken ConfigMap manifest
cat > ~/configmap.yaml <<'EOF'
apiVersion: v1
kind: ConfigMap
metadata:
  name: app-config
data:
  DATABASE_HOST: db.example.com
  DATABASE_PORT: 5432
  LOG_LEVEL: info
  MAX_CONNECTIONS: 100
EOF

# Create Pod that references ConfigMap with wrong name
cat > ~/pod.yaml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: myapp:latest
    envFrom:
    - configMapRef:
        name: application-config
EOF
