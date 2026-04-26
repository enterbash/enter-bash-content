# Solution: Use Init Process in Containers

## What the validator checks

- with-init container is not running
- with-init doesn't have init as PID 1 (got: <value>)
- --init flag not set — PID 1 is '<value>', expected init/tini

## Solution

```bash
docker run -d --name with-init --init alpine sleep infinity

# Verify PID 1 is an init process (tini)
docker exec with-init ps -o comm= -p 1   # should show "init" or "tini"
```

`--init` injects `tini` as PID 1, which properly handles zombie processes and signal forwarding.
