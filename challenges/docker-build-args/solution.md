# Solution: Use Build Arguments in Dockerfile

## What the validator checks

- argapp:latest image not found
- version.txt doesn't contain 2.0.0 (got: $OUTPUT)
- version.txt doesn't contain production (got: $OUTPUT)

## Solution

```bash
cat > ~/myapp/Dockerfile << 'EOF'
FROM alpine:latest
ARG APP_VERSION=1.0.0
ARG APP_ENV=production
RUN echo "version=$APP_VERSION env=$APP_ENV" > /app/config.txt
CMD ["cat", "/app/config.txt"]
EOF

docker build -t myapp:latest \
  --build-arg APP_VERSION=2.0.0 \
  --build-arg APP_ENV=staging \
  ~/myapp/
```
