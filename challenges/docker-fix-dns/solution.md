# Solution: Fix DNS Resolution in Containers

## What the validator checks

- dnsbox-fixed container is not running
- DNS is not set to 8.8.8.8 (got <value>)

## Solution

```bash
docker rm -f dnsbox

docker run -d \
  --name dnsbox-fixed \
  --dns 8.8.8.8 \
  alpine sleep infinity

docker exec dnsbox-fixed nslookup google.com
```

The broken container used `192.0.2.1` (a documentation IP). `--dns 8.8.8.8` sets a working resolver.
