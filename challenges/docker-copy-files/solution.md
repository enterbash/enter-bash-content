# Solution: Copy Files In and Out of Containers

## Approach

Use `docker cp` to copy files between host and container in both directions.

```bash
# Copy FROM container TO host
docker cp filebox:/var/log/app.log ~/extracted.log

# Create a file to inject
echo "mode=active" > ~/inject.conf

# Copy FROM host TO container
docker cp ~/inject.conf filebox:/etc/inject.conf

# Verify
cat ~/extracted.log
docker exec filebox cat /etc/inject.conf
```

## Why this works

`docker cp src dest` copies files. Use `container:/path` syntax for container paths. Works for both running and stopped containers.
