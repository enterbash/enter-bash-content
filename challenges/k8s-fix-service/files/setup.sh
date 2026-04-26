#!/bin/bash
# Create a broken Service manifest
cat > ~/service.yaml <<'EOF'
apiVersion: v2
kind: Service
metadata:
  name: web-app-svc
spec:
  type: ClusterIP
  selector:
    app: webapp
  ports:
    - protocol: TCP
      port: "80"
      targetPort: "8080"
EOF
