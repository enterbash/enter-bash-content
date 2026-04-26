#!/bin/bash
# Create pod with wrong DNS policy
cat > ~/pod.yaml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: custom-dns-pod
  labels:
    app: dns-test
spec:
  dnsPolicy: Default
  containers:
  - name: app
    image: nginx:1.25
    ports:
    - containerPort: 80
EOF
