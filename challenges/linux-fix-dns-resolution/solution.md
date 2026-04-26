# Solution: Fix DNS Resolution

## Approach

Replace the broken nameserver with a working public DNS server.

```bash
# View current resolv.conf
cat /etc/resolv.conf

# Fix it
echo "nameserver 8.8.8.8" | sudo tee /etc/resolv.conf
echo "nameserver 8.8.4.4" | sudo tee -a /etc/resolv.conf

# Test
nslookup google.com
```

## Why this works

`/etc/resolv.conf` controls DNS resolution. The broken nameserver `192.0.2.1` is a documentation IP (RFC 5737) that doesn't respond. Google's `8.8.8.8` is a reliable public resolver.
