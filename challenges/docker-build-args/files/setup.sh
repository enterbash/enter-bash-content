#!/bin/bash
# Setup: create project with incomplete Dockerfile
mkdir -p ~/argapp

cat > ~/argapp/Dockerfile << 'EOF'
FROM alpine:latest
WORKDIR /app
CMD ["cat", "/app/version.txt"]
EOF
