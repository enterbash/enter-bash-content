#!/bin/bash
# Setup: create a broken server image
mkdir -p ~/server

cat > ~/server/app.py << 'EOF'
from http.server import HTTPServer, SimpleHTTPRequestHandler
server = HTTPServer(('0.0.0.0', 8080), SimpleHTTPRequestHandler)
print('Server running on port 8080')
server.serve_forever()
EOF

cat > ~/server/Dockerfile << 'EOF'
FROM python:3-alpine
WORKDIR /app
COPY app.py .
ENTRYPOINT pythonn app.py
EOF

sudo docker build -t broken-server:latest ~/server 2>/dev/null || true
