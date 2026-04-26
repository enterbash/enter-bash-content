# Solution: Clean Up Unused Docker Resources

## What the validator checks

- there are still stopped containers
- unused networks still exist

## Solution

```bash
# Remove stopped containers
docker rm old1 old2 old3

# Remove unused networks
docker network rm unused-net1 unused-net2

# Remove dangling images
docker image prune -f

# Verify
docker ps -a --filter status=exited
docker network ls
```
