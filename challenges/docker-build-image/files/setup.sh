#!/bin/bash
# Setup: create a simple Python app with Dockerfile
mkdir -p ~/myapp

cat > ~/myapp/app.py << 'EOF'
from http.server import HTTPServer, SimpleHTTPRequestHandler
import os

class Handler(SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        self.wfile.write(b'Hello from myapp!\n')

if __name__ == '__main__':
    server = HTTPServer(('0.0.0.0', 8080), Handler)
    print('Server running on port 8080')
    server.serve_forever()
EOF

cat > ~/myapp/Dockerfile << 'EOF'
FROM python:3-alpine
WORKDIR /app
COPY app.py .
EXPOSE 8080
CMD ["python", "app.py"]
EOF
