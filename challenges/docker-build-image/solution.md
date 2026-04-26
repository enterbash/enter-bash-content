# Solution: Build a Docker Image

## What the validator checks

- myapp:latest image not found

## Solution

```bash
mkdir -p ~/myapp
cat > ~/myapp/Dockerfile << 'EOF'
FROM alpine:latest
RUN echo "Hello from myapp" > /app/hello.txt
CMD ["cat", "/app/hello.txt"]
EOF

docker build -t myapp:latest ~/myapp/
docker images | grep myapp
```

The validator checks that `myapp:latest` exists in `docker images`.
