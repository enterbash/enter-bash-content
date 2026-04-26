# Solution: Create a PriorityClass

## Solution

```yaml
apiVersion: scheduling.k8s.io/v1
kind: PriorityClass
metadata:
  name: high-priority
value: 1000000
globalDefault: false
description: "High priority workloads"
```

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: priority-pod
spec:
  priorityClassName: high-priority
  containers:
  - name: app
    image: nginx:alpine
```

## Why this works

Higher `value` means higher priority. When resources are scarce, the scheduler preempts lower-priority Pods to make room for higher-priority ones. `globalDefault: false` means it's not applied to all Pods automatically.
