# Solution: Create a DaemonSet

## Solution

```yaml
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: log-collector
spec:
  selector:
    matchLabels:
      app: log-collector
  template:
    metadata:
      labels:
        app: log-collector
    spec:
      containers:
      - name: collector
        image: alpine
        command: ["sh", "-c", "while true; do echo 'collecting logs'; sleep 60; done"]
        volumeMounts:
        - name: varlog
          mountPath: /var/log
          readOnly: true
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
```

## Why this works

DaemonSets run exactly one Pod per node. They're used for node-level agents: log collectors, monitoring, network plugins. `hostPath` mounts the node's filesystem into the container.
