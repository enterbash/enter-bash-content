#!/bin/bash
# Create pod without sidecar
cat > ~/pod.yaml <<'EOF'
apiVersion: v1
kind: Pod
metadata:
  name: app-with-logging
  labels:
    app: myapp
spec:
  containers:
  - name: app
    image: nginx:1.25
    command: ["sh", "-c", "while true; do echo $(date) Request processed >> /var/log/app/app.log; sleep 5; done"]
    volumeMounts:
    - name: log-volume
      mountPath: /var/log/app
  volumes:
  - name: log-volume
    emptyDir: {}
EOF
