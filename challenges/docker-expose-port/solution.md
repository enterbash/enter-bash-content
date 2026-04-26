# Solution: Expose and Map Container Ports

## Approach

Re-run the container with the correct port mapping.

```bash
# Remove the existing container
docker rm -f webserver

# Run with port mapping
docker run -d   --name webserver   -p 8080:80   nginx:alpine

# Verify
curl http://localhost:8080
```

## Why this works

`-p host_port:container_port` maps a port on the host to a port inside the container. Without `-p`, the container port is only accessible from within Docker networks.
