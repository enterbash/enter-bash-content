# Solution: Run Containers as Non-Root

## Approach

Fix the Dockerfile to add a non-root user with UID 1001.

```dockerfile
FROM alpine:latest
WORKDIR /app
COPY app.sh .
RUN chmod +x app.sh &&     adduser -D -u 1001 appuser
USER appuser
CMD ["./app.sh"]
```

```bash
docker build -t safebox:latest ~/nonroot/
docker run -d --name safebox safebox:latest sleep infinity
docker exec safebox id -u  # should return 1001
```

## Why this works

`adduser -D -u 1001 appuser` creates a user with UID 1001. `USER appuser` switches to that user for all subsequent instructions and the container runtime.
