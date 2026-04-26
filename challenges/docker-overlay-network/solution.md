# Solution: Create Overlay Networks

## Approach

Initialize Docker Swarm and create an overlay network with a service.

```bash
# Initialize swarm
docker swarm init

# Create overlay network
docker network create --driver overlay --attachable myoverlay

# Deploy a service on the overlay network
docker service create   --name web-service   --network myoverlay   --replicas 2   nginx:alpine

# Verify
docker network ls | grep overlay
docker service ls
```

## Why this works

Overlay networks span multiple Docker hosts in a swarm. `--attachable` allows standalone containers to connect. Services on the same overlay network can communicate by service name.
