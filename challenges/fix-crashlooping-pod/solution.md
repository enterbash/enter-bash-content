# Solution: Fix CrashLooping Pod

## Solution

Fix the invalid command in the Pod manifest and re-apply it.

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: web-app
spec:
  containers:
  - name: web
    image: nginx:alpine
    # Option 1: remove the command entirely (use image default)
    ports:
    - containerPort: 80
```

Or keep a command but use the correct binary:
```yaml
    command: ["nginx", "-g", "daemon off;"]
```

```bash
# Apply the fix
kubectl apply -f ~/pod.yaml

# Watch it come up
kubectl get pod web-app -w
```

## Why this works

`nginx-wrong` doesn't exist in the image, causing `exec format error` and immediate crash. Removing `command:` lets nginx use its default entrypoint. The Pod transitions from `CrashLoopBackOff` to `Running`.
