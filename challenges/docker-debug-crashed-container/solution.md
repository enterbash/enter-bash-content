# Solution: Debug a Crashed Container

## Approach

Inspect the crashed container's logs and exit code to diagnose the issue.

```bash
# Check container status
docker ps -a | grep webapp

# Read the logs
docker logs webapp

# Check exit code
docker inspect webapp --format '{{.State.ExitCode}}'

# Start a new container with the same image to debug interactively
docker run -it --rm --entrypoint sh $(docker inspect webapp --format '{{.Config.Image}}')

# Fix the issue (e.g., missing file, wrong command)
# Then restart
docker start webapp
```

## Why this works

`docker logs` shows stdout/stderr even from stopped containers. The exit code tells you how it failed (1 = general error, 126 = permission denied, 127 = command not found).
