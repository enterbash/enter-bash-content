# Solution: Fix an Ingress Manifest

## Solution

```yaml
apiVersion: networking.k8s.io/v1    # not extensions/v1beta1
kind: Ingress
metadata:
  name: web-ingress
spec:
  rules:
  - host: example.com
    http:
      paths:
      - path: /
        pathType: Prefix              # required in networking.k8s.io/v1
        backend:
          service:                    # new format (not serviceName/servicePort)
            name: web-svc
            port:
              number: 80
```

## Why this works

`extensions/v1beta1` Ingress was removed in Kubernetes 1.22. The new `networking.k8s.io/v1` API requires `pathType` and uses a nested `service:` block instead of flat `serviceName`/`servicePort` fields.
