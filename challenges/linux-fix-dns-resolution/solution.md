# Solution: Fix DNS Resolution

## What the validator checks

- **Check that resolv.conf has valid nameservers**: /etc/resolv.conf does not contain a valid public nameserver
- **Check that DNS resolution works**: DNS resolution is still not working

## Solution

```bash
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf
nslookup google.com
```
