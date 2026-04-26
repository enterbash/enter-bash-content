# Solution: Fix an Ingress Manifest

## What the validator checks

- ~/ingress.yaml not found
- ingress.yaml does not pass validation
- apiVersion should be networking.k8s.io/v1
- pathType is required in networking.k8s.io/v1
- backend should use new service format
- service name should be web-svc

## Solution

```yaml
apiVersion: networking.k8s.io/v1    # not extensions/v1beta1 (removed in 1.22)
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
