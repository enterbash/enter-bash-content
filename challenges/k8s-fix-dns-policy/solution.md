# Solution: Fix DNS Policy

## Solution

```yaml
apiVersion: v1
kind: Pod
metadata:
  name: dns-pod
spec:
  dnsPolicy: ClusterFirst    # not "None" without dnsConfig
  containers:
  - name: app
    image: alpine
    command: ["sleep", "infinity"]
```

## Why this works

`dnsPolicy: None` requires a `dnsConfig` block with explicit nameservers. `ClusterFirst` uses the cluster DNS (CoreDNS) which resolves both cluster-internal names and external names.
