# Solution: Fix File Permission Issues in Containers

## What the validator checks

- permbox container is not running
- container is running as root
- /app/data is not writable

## Solution

```dockerfile
FROM alpine:latest
RUN adduser -D -u 1001 appuser && \
    mkdir -p /app/data && \
    chown -R appuser:appuser /app
USER appuser
WORKDIR /app
CMD ["sh", "-c", "while true; do sleep 1; done"]
```

```bash
docker build -t fixed-app:latest ~/app/
docker run -d --name permbox fixed-app:latest
docker exec permbox id   # should show uid=1001
```
