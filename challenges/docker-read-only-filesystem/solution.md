# Solution: Run Containers with Read-Only Filesystem

## What the validator checks

- readonly-web container is not running
- root filesystem is not read-only
- /var/cache/nginx tmpfs not found
- /var/run tmpfs not found
- was able to write to read-only filesystem

## Solution

```bash
docker run -d \
  --name readonly-web \
  --read-only \
  --tmpfs /var/cache/nginx \
  --tmpfs /var/run \
  --tmpfs /tmp \
  nginx:alpine

# Verify
docker exec readonly-web touch /test.txt 2>&1   # should fail
docker exec readonly-web touch /tmp/test.txt    # should succeed
```
