# Solution: Fix ImagePullBackOff

## What the validator checks

- ~/pod.yaml not found
- pod.yaml does not pass validation
- image name has a typo (ngnix)
- image tag has a typo (latst)
- image should be nginx:1.25

## Solution

```yaml
spec:
  containers:
  - name: app
    image: nginx:1.25           # fix typo in image name/tag
    imagePullPolicy: IfNotPresent
```
