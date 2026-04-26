# Solution: Fix DNS Policy

## What the validator checks

- ~/pod.yaml not found
- pod.yaml does not pass validation
- dnsPolicy should be None
- dnsConfig section is required
- nameservers should include 8.8.8.8
- nameservers should include 8.8.4.4
- searches should include svc.cluster.local
- options should include ndots

## Solution

```yaml
spec:
  dnsPolicy: ClusterFirst    # not "None" without a dnsConfig block
  containers:
  - name: app
    image: alpine
    command: ["sleep", "infinity"]
```
