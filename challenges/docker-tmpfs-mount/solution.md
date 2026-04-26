# Solution: Use tmpfs Mounts

## Approach

Mount tmpfs filesystems for in-memory storage.

```bash
# Container with tmpfs cache
docker run -d   --name tmpbox   --tmpfs /app/cache:size=64m   alpine sleep infinity

# Container with secure tmpfs (no exec, no suid)
docker run -d   --name securebox   --tmpfs /run/secrets:noexec,nosuid,size=32m   alpine sleep infinity

# Verify
docker inspect tmpbox --format '{{json .HostConfig.Tmpfs}}'
```

## Why this works

`--tmpfs` mounts a temporary in-memory filesystem. Data is lost when the container stops. Options like `noexec` and `nosuid` add security constraints.
