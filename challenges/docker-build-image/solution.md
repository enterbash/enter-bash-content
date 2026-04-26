# Solution: Build a Docker Image

## Approach

Create a `Dockerfile` and build the image.

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

## Why this works

`docker build -t name:tag context/` builds an image from a Dockerfile in the given directory. The `-t` flag tags it with a name and version.
