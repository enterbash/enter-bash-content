# Solution: Set Resource Limits on Containers

## Approach

Run a container with memory and CPU limits.

```bash
docker run -d   --name limited   --memory 128m   --cpus 0.5   nginx:alpine

# Verify limits
docker inspect limited --format '{{.HostConfig.Memory}}'      # 134217728 (128MB in bytes)
docker inspect limited --format '{{.HostConfig.NanoCpus}}'    # 500000000 (0.5 CPUs)
```

## Why this works

`--memory` sets a hard memory limit. `--cpus` limits CPU usage as a fraction of one core. These prevent a single container from starving other processes.
