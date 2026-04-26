# Solution: Fix Volume Mounts

## Solution

The volume names in `volumeMounts` must exactly match the names in `volumes`.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: volume-pod
spec:
  containers:
  - name: app
    image: nginx:alpine
    volumeMounts:
    - name: config-vol      # must match volumes[].name below
      mountPath: /etc/config
    - name: data-vol        # must match volumes[].name below
      mountPath: /data
  volumes:
  - name: config-vol        # matches volumeMounts[0].name
    configMap:
      name: app-config
  - name: data-vol          # matches volumeMounts[1].name
    emptyDir: {}
```

## Why this works

`volumeMounts[].name` is a reference to `volumes[].name`. A mismatch causes the Pod to fail with `MountVolume.SetUp failed`.
