#!/bin/bash
# Create pod with broken tolerations
cat > ~/pod.yaml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: gpu-pod
  labels:
    app: ml-training
spec:
  containers:
  - name: trainer
    image: tensorflow/tensorflow:latest-gpu
    resources:
      limits:
        nvidia.com/gpu: "1"
  tolerations:
  - key: "dedicated"
    operator: "Exists"
    value: "gpu"
    effect: "NoSchedule"
  - key: "maintenance"
    operator: "Equal"
    effect: "NoExecute"
EOF
