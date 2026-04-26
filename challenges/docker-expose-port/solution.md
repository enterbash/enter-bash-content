# Solution: Expose and Map Container Ports

## What the validator checks

- webserver container is not running
- port 80 is not mapped
- cannot reach webserver on port 8080

## Solution

```bash
# Remove the container without port mapping
docker rm -f webserver

# Re-run with port mapping
docker run -d \
  --name webserver \
  -p 8080:80 \
  nginx:alpine

curl http://localhost:8080
```

`-p host_port:container_port` maps a host port to a container port.
