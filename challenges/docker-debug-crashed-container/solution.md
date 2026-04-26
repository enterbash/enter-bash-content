# Solution: Debug a Crashed Container

## What the validator checks

- webapp-fixed container is not running
- /app/config.json not found in container

## Solution

```bash
# Check container status and exit code
docker ps -a | grep webapp
docker inspect webapp --format '{{.State.ExitCode}}'

# Read the logs
docker logs webapp

# Debug interactively with same image
docker run -it --rm --entrypoint sh \
  $(docker inspect webapp --format '{{.Config.Image}}')

# After fixing, restart
docker start webapp
```
