# Solution: Set Resource Limits on Containers

## What the validator checks

- limited container is not running
- memory limit is not 128MB (got <value>)
- CPU limit is not 0.5 (got <value>)

## Solution

```bash
docker run -d \
  --name limited \
  --memory 128m \
  --cpus 0.5 \
  nginx:alpine

# Verify
docker inspect limited --format '{{.HostConfig.Memory}}'    # 134217728 (128MB)
docker inspect limited --format '{{.HostConfig.NanoCpus}}'  # 500000000 (0.5 CPU)
```
