# Solution: Execute Commands in Running Containers

## What the validator checks

- workbox container is not running
- /tmp/hello.txt doesn't contain 'Hello from exec'
- curl is not installed
- /app/logs directory not found

## Solution

```bash
# Run an interactive shell
docker exec -it workbox sh

# Run a single command
docker exec workbox ls /

# Create a file inside the container
docker exec workbox sh -c "echo 'hello' > /tmp/test.txt"
docker exec workbox cat /tmp/test.txt
```

`-it` allocates a pseudo-TTY for interactive use.
