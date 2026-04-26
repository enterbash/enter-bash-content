# Solution: Add Init Containers

## What the validator checks

- ~/pod.yaml not found
- pod.yaml does not pass validation
- initContainers section is missing
- init container name should be content-init
- init container image should be busybox
- init container should mount volume at /work-dir

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

Init containers run to completion before app containers start.
