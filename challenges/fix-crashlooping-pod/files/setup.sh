#!/bin/bash
# Create a pod with a bad command that will crashloop
kubectl apply -f - <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: web-app
spec:
  containers:
  - name: web
    image: nginx:alpine
    command: ["nginx-wrong", "-g", "daemon off;"]
EOF
