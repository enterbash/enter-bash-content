# Solution: Docker Container Networking

## Approach

Connect the client container to the web container's network.

```bash
# Check current networks
docker network ls
docker inspect web | grep -A5 Networks

# Connect client to web's network
docker network connect net-web client

# Verify
docker exec client curl -sf http://web:8080
```

## Why this works

The setup put `web` on `net-web` and `client` on `net-client`. Connecting `client` to `net-web` gives it access to `web` by name.
