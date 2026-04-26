# Solution: Link Containers (Legacy)

## Approach

Use `--link` to connect containers (legacy feature).

```bash
# Start the redis server
docker run -d --name redis-server redis:alpine

# Link the client to the server using an alias
docker run -d   --name redis-client   --link redis-server:db   alpine sleep infinity

# Verify the link works (db resolves to redis-server's IP)
docker exec redis-client ping -c 2 db
```

## Why this works

`--link source:alias` adds the source container's IP to the client's `/etc/hosts` under the alias name. Note: `--link` is legacy — prefer custom networks for new projects.
