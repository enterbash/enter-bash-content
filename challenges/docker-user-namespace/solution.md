# Solution: Run Containers as Non-Root

## What the validator checks

- safebox container is not running
- container is running as root (uid 0)
- container should run as uid 1001 (got <value>)

## Solution

```dockerfile
FROM alpine:latest
WORKDIR /app
COPY app.sh .
RUN chmod +x app.sh && \
    adduser -D -u 1001 appuser
USER appuser
CMD ["./app.sh"]
```

```bash
docker build -t safebox:latest ~/nonroot/
docker run -d --name safebox safebox:latest sleep infinity
docker exec safebox id -u   # should return 1001
```
