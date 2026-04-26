# Solution: Fix a NetworkPolicy

## Solution

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-policy
spec:
  podSelector:
    matchLabels:
      app: api           # target the api pods
  policyTypes:
  - Ingress
  - Egress              # must include Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend  # only allow from frontend
    ports:
    - port: 8080
  egress:               # allow all egress (empty = allow all)
  - {}
```

## Why this works

Including `Egress` in `policyTypes` without an `egress:` rule would block all outbound traffic. An empty `egress: [{}]` allows all egress while still declaring the policy type.
