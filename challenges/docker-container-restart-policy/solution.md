# Solution: Set Container Restart Policies

## What the validator checks

- always-up restart policy is '$POL1' (expected 'always')
- on-fail restart policy is '$POL2' (expected 'on-failure')
- on-fail max retries is '$MAX2' (expected '3')
- unless-manual restart policy is '$POL3' (expected 'unless-stopped')

## Solution

```bash
docker run -d --name always-up    --restart always          alpine sleep infinity
docker run -d --name on-fail      --restart on-failure:3    alpine sleep infinity
docker run -d --name unless-manual --restart unless-stopped  alpine sleep infinity

# Verify
docker inspect always-up --format '{{.HostConfig.RestartPolicy.Name}}'
```
