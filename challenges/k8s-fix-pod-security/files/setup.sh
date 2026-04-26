#!/bin/bash
# Create pod with missing security context
cat > ~/pod.yaml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: secure-app
  labels:
    app: secure
spec:
  containers:
  - name: app
    image: nginx:1.25
    ports:
    - containerPort: 8080
    securityContext:
      privileged: true
      runAsUser: 0
EOF
