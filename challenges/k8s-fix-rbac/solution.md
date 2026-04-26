# Solution: Fix RBAC Permissions

## What the validator checks

- role.yaml or rolebinding.yaml not found
- role.yaml does not pass validation
- rolebinding.yaml does not pass validation
- roleRef.kind should be Role
- roleRef.name should be pod-reader

## Solution

```yaml
# role.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: Role
metadata:
  name: pod-reader
  namespace: default
rules:
- apiGroups: [""]
  resources: ["pods"]
  verbs: ["get", "list", "watch"]
---
# rolebinding.yaml
apiVersion: rbac.authorization.k8s.io/v1
kind: RoleBinding
metadata:
  name: read-pods
  namespace: default
subjects:
- kind: ServiceAccount
  name: default
  namespace: default
roleRef:
  kind: Role           # must be "Role" not "ClusterRole"
  name: pod-reader     # must match Role name above
  apiGroup: rbac.authorization.k8s.io
```
