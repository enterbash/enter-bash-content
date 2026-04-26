#!/bin/bash
# Create pod with wrong image name causing ImagePullBackOff
cat > ~/pod.yaml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: web-app
spec:
  containers:
  - name: web
    image: ngnix:latst
    ports:
    - containerPort: 80
    imagePullPolicy: Always
EOF
