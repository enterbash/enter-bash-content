# Solution: Fix CrashLooping Pod

## What the validator checks


## Solution

The pod crashes because `nginx-wrong` doesn't exist in the image.

Fix `~/pod.yaml` — either remove the `command:` entirely (use image default) or use the correct binary:

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-app
spec:
  containers:
  - name: web
    image: nginx:alpine
    # Option 1: remove command entirely (recommended)
    ports:
    - containerPort: 80
```

Or keep a command with the correct binary:
```yaml
    command: ["nginx", "-g", "daemon off;"]
```

```bash
kubectl apply -f ~/pod.yaml
kubectl get pod web-app -w   # watch it reach Running
```
