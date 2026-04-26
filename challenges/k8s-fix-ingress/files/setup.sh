#!/bin/bash
# Create broken Ingress manifest (uses old v1beta1 format)
cat > ~/ingress.yaml <<'EOF'
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: web-ingress
spec:
  ingressClassName: nginx
  rules:
  - host: app.example.com
    http:
      paths:
      - path: /
        backend:
          serviceName: web-svc
          servicePort: 80
EOF
