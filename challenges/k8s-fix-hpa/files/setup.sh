#!/bin/bash
# Create broken HPA manifest
cat > ~/hpa.yaml <<'EOF'
apiVersion: autoscaling/v1
kind: HorizontalPodAutoscaler
metadata:
  name: web-app-hpa
spec:
  scaleTargetRef:
    apiVersion: apps/v1
    kind: Deploy
    name: web-app
  minReplicas: 2
  maxReplicas: 10
  targetCPUUtilizationPercentage: 70
EOF
