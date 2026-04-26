# Solution: Docker Container Networking

## What the validator checks

- web container is not running
- client container is not running
- client cannot reach web container

## Solution

The `web` container is on `net-web` and `client` is on `net-client` — they can't communicate. Connect `client` to `net-web`:

```bash
docker network connect net-web client

# Verify
docker exec client curl -sf http://web:8080
```
