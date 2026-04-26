# Solution: Use tmpfs Mounts

## What the validator checks

- tmpbox container is not running
- securebox container is not running
- /app/cache tmpfs not found on tmpbox
- /run/secrets tmpfs not found on securebox

## Solution

```bash
docker run -d \
  --name tmpbox \
  --tmpfs /app/cache:size=64m \
  alpine sleep infinity

docker run -d \
  --name securebox \
  --tmpfs /run/secrets:noexec,nosuid,size=32m \
  alpine sleep infinity

docker inspect tmpbox --format '{{json .HostConfig.Tmpfs}}'
```
