#!/bin/bash
set -e

# Create the application
mkdir -p /opt/myapp
cat > /opt/myapp/server.py <<'PYTHON'
#!/usr/bin/env python3
from http.server import HTTPServer, SimpleHTTPRequestHandler
import os

class Handler(SimpleHTTPRequestHandler):
    def do_GET(self):
        self.send_response(200)
        self.send_header('Content-type', 'text/plain')
        self.end_headers()
        self.wfile.write(b'myapp is running')

if __name__ == '__main__':
    server = HTTPServer(('0.0.0.0', 8080), Handler)
    print('Server running on port 8080')
    server.serve_forever()
PYTHON
chmod +x /opt/myapp/server.py
chown -R runner:runner /opt/myapp

# Remove any existing service file
rm -f /etc/systemd/system/myapp.service
systemctl daemon-reload 2>/dev/null || true
