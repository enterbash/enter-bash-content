# Solution: Fix DNS Resolution in Containers

## Approach

Re-run the container with a working DNS server.

```bash
# Remove the broken container
docker rm -f dnsbox

# Run with correct DNS
docker run -d   --name dnsbox-fixed   --dns 8.8.8.8   alpine sleep infinity

# Verify DNS works
docker exec dnsbox-fixed nslookup google.com
```

## Why this works

`--dns` overrides the DNS server for the container. The broken container used `192.0.2.1` (a documentation IP that doesn't respond). Google's `8.8.8.8` is a reliable public resolver.
