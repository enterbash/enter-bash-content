# Solution: Create Overlay Networks

## What the validator checks

- Docker Swarm is not initialized
- app-overlay network not found or not overlay type
- web-service not found
- web-service should have 2/2 replicas (got $REPLICAS)

## Solution

```bash
docker swarm init
docker network create --driver overlay --attachable myoverlay

docker service create \
  --name web-service \
  --network myoverlay \
  --replicas 2 \
  nginx:alpine

docker network ls | grep overlay
docker service ls
```
