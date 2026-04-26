# Solution: Fix ImagePullBackOff

## Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: image-pod
spec:
  containers:
  - name: app
    image: nginx:1.25        # fix: use a valid, accessible image tag
    imagePullPolicy: IfNotPresent
```

## Why this works

`imagePullPolicy: Always` forces a pull every time, which fails if the registry is unreachable. `IfNotPresent` uses the cached image if available. Also ensure the image name and tag are correct — a typo causes `ImagePullBackOff`.
