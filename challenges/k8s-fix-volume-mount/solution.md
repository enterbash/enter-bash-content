# Solution: Fix Volume Mounts

## What the validator checks

- ~/pod.yaml not found
- pod.yaml does not pass validation
- should mount at /etc/config
- should mount at /data

## Solution

The `volumeMounts[].name` must exactly match `volumes[].name`.

```yaml
spec:
  containers:
  - name: app
    image: nginx:alpine
    volumeMounts:
    - name: config-vol      # must match volumes[].name below
      mountPath: /etc/config
    - name: data-vol
      mountPath: /data
  volumes:
  - name: config-vol        # matches volumeMounts[0].name
    configMap:
      name: app-config
  - name: data-vol
    emptyDir: {}
```
