# Solution: Set Container Restart Policies

## Approach

Run containers with different restart policies.

```bash
# always: restart regardless of exit code
docker run -d --name always-up --restart always alpine sleep infinity

# on-failure with max retries
docker run -d --name on-fail --restart on-failure:3 alpine sleep infinity

# unless-stopped: restart unless manually stopped
docker run -d --name unless-manual --restart unless-stopped alpine sleep infinity

# Verify policies
docker inspect always-up --format '{{.HostConfig.RestartPolicy.Name}}'
docker inspect on-fail --format '{{.HostConfig.RestartPolicy.MaximumRetryCount}}'
```

## Why this works

Restart policies control what Docker does when a container exits. `always` restarts even after `docker stop`. `unless-stopped` doesn't restart after a manual stop.
