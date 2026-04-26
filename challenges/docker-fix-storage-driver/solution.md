# Solution: Fix Docker Storage Issues

## What the validator checks

- storebox-fixed container is not running
- cannot write to /data
- /tmp tmpfs mount not found

## Solution

```bash
docker rm -f storebox

docker run -d \
  --name storebox \
  -v ~/storage:/data \
  -u $(id -u):$(id -g) \
  --tmpfs /tmp \
  alpine sleep infinity

docker exec storebox id
docker exec storebox touch /tmp/test.txt && echo "tmpfs writable"
```
