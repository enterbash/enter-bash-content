#!/bin/bash
# Create pod with broken volume mounts
cat > ~/pod.yaml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: data-app
spec:
  containers:
  - name: app
    image: nginx:1.25
    volumeMounts:
    - name: config-vol
      mountPath: /etc/config
    - name: data-vol
      mountPath: /data
  volumes:
  - name: config-volume
    configMap:
      name: app-config
  - name: data-volume
    emptyDir: {}
EOF
