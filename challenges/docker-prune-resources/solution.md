# Solution: Clean Up Unused Docker Resources

## Approach

Remove stopped containers, unused networks, and dangling images.

```bash
# Remove specific stopped containers
docker rm old1 old2 old3

# Or remove all stopped containers
docker container prune -f

# Remove unused networks
docker network rm unused-net1 unused-net2
# Or remove all unused networks
docker network prune -f

# Remove dangling images (untagged)
docker image prune -f

# Nuclear option — remove everything unused
docker system prune -f

# Verify
docker ps -a --filter status=exited
docker network ls
```

## Why this works

`docker prune` commands remove unused resources. `-f` skips the confirmation prompt. `docker system prune` combines container, network, and image cleanup.
