#!/bin/bash
# Create deployment and service with mismatched labels
cat > ~/deployment.yaml <<'EOF'
apiVersion: apps/v1
kind: Deployment
metadata:
  name: api-server
  labels:
    app: api-server
spec:
  replicas: 2
  selector:
    matchLabels:
      app: api
  template:
    metadata:
      labels:
        app: api-server
    spec:
      containers:
      - name: api
        image: nginx:1.25
        ports:
        - containerPort: 8080
EOF

cat > ~/service.yaml <<'EOF'
apiVersion: v1
kind: Service
metadata:
  name: api-server-svc
spec:
  type: ClusterIP
  selector:
    app: api-svc
  ports:
  - port: 80
    targetPort: 8080
EOF
