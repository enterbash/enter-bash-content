#!/bin/bash
# Create pod with broken env vars
cat > ~/pod.yaml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: app-pod
spec:
  containers:
  - name: app
    image: myapp:latest
    env:
    - name: DATABASE_URL
      value: postgres://db:5432/mydb
    - name: API_KEY
      valueFrom:
        secretKeyRef:
          name: app-secrets
          key: api-key
    - name: CONFIG_MODE
      valueFrom:
        configMapKeyRef:
          name: app-settings
          key: mode
    - name: POD_NAME
      valueFrom:
        fieldRef:
          fieldPath: metadata.labels
    - name: NODE_NAME
      valueFrom:
        fieldRef:
          fieldPath: spec.nodename
EOF
