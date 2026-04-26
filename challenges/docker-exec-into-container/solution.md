# Solution: Execute Commands in Running Containers

## Approach

Use `docker exec` to run commands inside a running container.

```bash
# Run an interactive shell
docker exec -it workbox sh

# Run a single command
docker exec workbox ls /

# Run as a specific user
docker exec -u root workbox whoami

# Create a file inside the container
docker exec workbox sh -c "echo 'hello' > /tmp/test.txt"
docker exec workbox cat /tmp/test.txt
```

## Why this works

`docker exec` runs a command in a running container. `-it` allocates a pseudo-TTY and keeps stdin open for interactive use. `-u` specifies the user.
