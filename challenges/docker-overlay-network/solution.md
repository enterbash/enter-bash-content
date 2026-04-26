# Solution: Create Overlay Networks

## What the validator checks

- Docker Swarm is not initialized
- app-overlay network not found or not overlay type
- web-service not found
- web-service should have 2/2 replicas (got <value>)

## Solution

```bash
docker swarm init
docker network create --driver overlay --attachable app-overlay

docker service create \
  --name web-service \
  --network app-overlay \
  --replicas 2 \
  nginx:alpine

docker network ls | grep overlay
docker service ls   # should show web-service  2/2
```
