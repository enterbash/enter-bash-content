# Solution: Create a DaemonSet

## What the validator checks

- ~/daemonset.yaml not found
- daemonset.yaml does not pass validation
- kind should be DaemonSet
- DaemonSet name should be log-collector
- image should be fluentd
- should mount /var/log
- should use hostPath volume
- labels should include app: log-collector

## Solution

```yaml
# ~/daemonset.yaml
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
        command: ["sh", "-c", "while true; do echo 'collecting'; sleep 60; done"]
        volumeMounts:
        - name: varlog
          mountPath: /var/log
          readOnly: true
      volumes:
      - name: varlog
        hostPath:
          path: /var/log
```
