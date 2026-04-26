# Solution: Add a Healthcheck to a Container

## Approach

Run a container with a `HEALTHCHECK` configured.

```bash
docker run -d   --name healthyweb   --health-cmd "wget -qO- http://localhost/ || exit 1"   --health-interval 10s   --health-timeout 5s   --health-retries 3   nginx:alpine

# Wait for health check to run
sleep 15

# Check health status
docker inspect healthyweb --format '{{.State.Health.Status}}'
```

## Why this works

`--health-cmd` runs periodically inside the container. Exit 0 = healthy, exit 1 = unhealthy. Docker marks the container status accordingly.
