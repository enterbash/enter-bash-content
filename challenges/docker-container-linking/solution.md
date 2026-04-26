# Solution: Link Containers (Legacy)

## What the validator checks

- redis-server container is not running
- redis-client container is not running
- redis-client cannot reach 'db' (link not working)

## Solution

```bash
docker run -d --name redis-server redis:alpine

docker run -d \
  --name redis-client \
  --link redis-server:db \
  alpine sleep infinity

# Verify the link (db resolves to redis-server's IP)
docker exec redis-client ping -c 2 db
```
