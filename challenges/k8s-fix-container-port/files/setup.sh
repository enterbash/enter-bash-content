#!/bin/bash
# Create pod and service with mismatched ports
cat > ~/pod.yaml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: node-app
  labels:
    app: node-app
spec:
  containers:
  - name: app
    image: node:18-alpine
    containerPort: 8080
    command: ["node", "-e", "require('http').createServer((req,res)=>{res.end('ok')}).listen(3000)"]
EOF

cat > ~/service.yaml <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: node-app-svc
spec:
  type: ClusterIP
  selector:
    app: node-application
  ports:
  - port: 80
    targetPort: 8080
EOF
