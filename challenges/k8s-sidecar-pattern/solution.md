# Solution: Implement Sidecar Pattern

## What the validator checks

- ~/pod.yaml not found
- pod.yaml does not pass validation
- sidecar container name should be log-shipper
- sidecar image should be busybox
- sidecar should mount log-volume
- sidecar volume mount should be readOnly: true

## Solution

```yaml
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
      readOnly: true
  volumes:
  - name: log-volume
    emptyDir: {}
```
