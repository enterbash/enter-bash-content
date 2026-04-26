# Solution: Run Containers with Read-Only Filesystem

## Approach

Run nginx with a read-only root filesystem and tmpfs for writable paths.

```bash
docker run -d   --name readonly-web   --read-only   --tmpfs /var/cache/nginx   --tmpfs /var/run   --tmpfs /tmp   nginx:alpine

# Verify read-only
docker exec readonly-web touch /test.txt 2>&1  # should fail
docker exec readonly-web touch /tmp/test.txt   # should succeed (tmpfs)
```

## Why this works

`--read-only` makes the root filesystem immutable. nginx needs to write to `/var/cache/nginx` and `/var/run` — `--tmpfs` mounts in-memory filesystems at those paths.
