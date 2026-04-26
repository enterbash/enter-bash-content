# Solution: Implement Sidecar Pattern

## Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: sidecar-pod
spec:
  containers:
  - name: app
    image: nginx:alpine
    volumeMounts:
    - name: log-volume
      mountPath: /var/log/nginx
  - name: log-shipper
    image: busybox
    command: ["sh", "-c", "tail -f /logs/access.log"]
    volumeMounts:
    - name: log-volume
      mountPath: /logs
      readOnly: true        # sidecar only reads logs
  volumes:
  - name: log-volume
    emptyDir: {}
```

## Why this works

The sidecar pattern uses a second container to augment the main container. Sharing a volume lets the log-shipper read logs written by nginx. `readOnly: true` prevents accidental writes.
