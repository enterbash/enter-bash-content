# Solution: Multi-Stage Docker Build

## Approach

Use a multi-stage build to compile in one stage and copy only the binary to a minimal final image.

```dockerfile
# Stage 1: build
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod .
COPY main.go .
RUN go build -o server .

# Stage 2: minimal runtime image
FROM alpine:latest
WORKDIR /app
COPY --from=builder /app/server .
EXPOSE 8080
CMD ["./server"]
```

```bash
docker build -t goapp:latest ~/goapp/
docker images goapp  # should be well under 50MB
```

## Why this works

The Go toolchain (~300MB) is only in the builder stage. The final image only contains the compiled binary and Alpine (~5MB). `COPY --from=builder` copies across stages.
