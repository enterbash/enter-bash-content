# Solution: Use Init Process in Containers

## Approach

Run the container with the `--init` flag to use Docker's init process as PID 1.

```bash
docker run -d --name with-init --init alpine sleep infinity

# Verify PID 1 is an init process
docker exec with-init ps -o comm= -p 1  # should show "init" or "tini"
```

## Why this works

`--init` injects `tini` as PID 1. This properly handles zombie processes (reaping orphaned children) and forwards signals to child processes — something a naive `sleep infinity` or app process doesn't do.
