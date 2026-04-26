# Solution: Create a Multi-Container Pod

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

## Why this works

Containers in the same Pod share the same network namespace (same IP) and can share volumes. The `emptyDir` volume is created when the Pod starts and deleted when it stops.
