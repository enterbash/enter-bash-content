# Solution: Use Build Arguments in Dockerfile

## Approach

Use `ARG` in the Dockerfile and pass values with `--build-arg`.

```dockerfile
FROM alpine:latest
ARG APP_VERSION=1.0.0
ARG APP_ENV=production
RUN echo "version=$APP_VERSION env=$APP_ENV" > /app/config.txt
CMD ["cat", "/app/config.txt"]
```

```bash
docker build -t myapp:latest   --build-arg APP_VERSION=2.0.0   --build-arg APP_ENV=staging   ~/myapp/
```

## Why this works

`ARG` declares a build-time variable. `--build-arg` passes the value. Unlike `ENV`, `ARG` values are not available in the running container.
