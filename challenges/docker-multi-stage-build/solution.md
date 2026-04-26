# Solution: Multi-Stage Docker Build

## What the validator checks

- goapp:latest image not found
- image is <value>, must be under 50MB
- image is <value>, must be under 50MB

## Solution

```dockerfile
# Stage 1: build
FROM golang:1.21-alpine AS builder
WORKDIR /app
COPY go.mod .
COPY main.go .
RUN go build -o server .

# Stage 2: minimal runtime
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

`COPY --from=builder` copies only the compiled binary — the Go toolchain (~300MB) stays in the builder stage.
