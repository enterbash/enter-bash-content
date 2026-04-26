# Solution: Fix a NetworkPolicy

## What the validator checks

- ~/netpol.yaml not found
- netpol.yaml does not pass validation
- podSelector should target app: api
- ingress should allow from app: frontend
- ingress port should be 8080
- policyTypes should include Egress
- egress section is required to allow all egress

## Solution

```yaml
apiVersion: networking.k8s.io/v1
kind: NetworkPolicy
metadata:
  name: api-policy
spec:
  podSelector:
    matchLabels:
      app: api
  policyTypes:
  - Ingress
  - Egress
  ingress:
  - from:
    - podSelector:
        matchLabels:
          app: frontend
    ports:
    - port: 8080
  egress:
  - {}              # allow all egress
```
