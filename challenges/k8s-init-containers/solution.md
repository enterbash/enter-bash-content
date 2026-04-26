# Solution: Add Init Containers

## Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: init-pod
spec:
  initContainers:
  - name: init-setup
    image: alpine
    command: ["sh", "-c", "echo 'initialized' > /shared/init.txt"]
    volumeMounts:
    - name: shared
      mountPath: /shared
  containers:
  - name: app
    image: alpine
    command: ["sh", "-c", "cat /shared/init.txt && sleep infinity"]
    volumeMounts:
    - name: shared
      mountPath: /shared
  volumes:
  - name: shared
    emptyDir: {}
```

## Why this works

Init containers run to completion before app containers start. They share volumes with app containers. Use them for setup tasks: waiting for dependencies, seeding data, or running migrations.
