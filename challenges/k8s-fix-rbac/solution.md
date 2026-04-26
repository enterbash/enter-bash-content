# Solution: Fix RBAC Permissions

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
```

```yaml
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
  name: pod-reader     # must match the Role name above
  apiGroup: rbac.authorization.k8s.io
```

## Why this works

`roleRef.kind` must be `Role` (not `ClusterRole`) when binding to a namespace-scoped Role. `roleRef.name` must exactly match the Role's `metadata.name`.
