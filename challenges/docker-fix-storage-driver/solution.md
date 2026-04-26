# Solution: Fix Docker Storage Issues

## Approach

Fix the container to use the correct user ID and add tmpfs for writable paths.

```bash
docker rm -f storebox

docker run -d   --name storebox   -v ~/storage:/data   -u $(id -u):$(id -g)   --tmpfs /tmp   alpine sleep infinity

# Verify
docker exec storebox id
docker exec storebox touch /tmp/test.txt && echo "tmpfs writable"
```

## Why this works

`-u $(id -u):$(id -g)` runs the container as your current user, matching the volume mount ownership. `--tmpfs` mounts a temporary in-memory filesystem for paths that need to be writable.
