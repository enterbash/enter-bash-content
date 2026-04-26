#!/bin/bash
# Setup: create a broken Dockerfile
mkdir -p ~/webapp

cat > ~/webapp/index.html << 'EOF'
<html><body><h1>Hello Docker!</h1></body></html>
EOF

cat > ~/webapp/Dockerfile << 'EOF'
FORM alpine:latest
WORKDIR /app
COPPY index.html .
RUN echoo "Build complete"
CMD ["httpd", "-f", "-p", "8080"]
EOF
