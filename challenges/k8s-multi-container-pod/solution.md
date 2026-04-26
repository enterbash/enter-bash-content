# Solution: Create a Multi-Container Pod

## What the validator checks

- ~/pod.yaml not found
- pod.yaml does not pass validation
- Pod name should be multi-container
- should have container named web
- should have container named content
- web container should use nginx image
- content container should use busybox image
- should have shared-data volume
- should use emptyDir volume

## Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: multi-container
spec:
  containers:
  - name: web
    image: nginx
    volumeMounts:
    - name: shared-data
      mountPath: /usr/share/nginx/html
  - name: content
    image: busybox
    command: ["sh", "-c", "while true; do echo '<h1>Hello</h1>' > /data/index.html; sleep 30; done"]
    volumeMounts:
    - name: shared-data
      mountPath: /data
  volumes:
  - name: shared-data
    emptyDir: {}
```
