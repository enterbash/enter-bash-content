# Solution: Fix File Permission Issues in Containers

## Approach

Fix the Dockerfile to create a non-root user and set correct directory permissions.

```dockerfile
FROM alpine:latest
RUN adduser -D -u 1001 appuser &&     mkdir -p /app/data &&     chown -R appuser:appuser /app
USER appuser
WORKDIR /app
CMD ["sh", "-c", "while true; do sleep 1; done"]
```

```bash
docker build -t fixed-app:latest ~/app/
docker run -d --name permbox fixed-app:latest
docker exec permbox id
docker exec permbox test -w /app/data && echo "writable"
```

## Why this works

Running as non-root reduces attack surface. The `chown` must happen before `USER` (while still root). `/app/data` needs to be owned by the app user to be writable.
