#!/bin/bash
set -e

# Create the application
sudo mkdir -p /opt/myapp
sudo tee /opt/myapp/server.py <<'PYTHON' > /dev/null
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
sudo chmod +x /opt/myapp/server.py
sudo chown -R runner:runner /opt/myapp

# Remove any existing service file
sudo rm -f /etc/systemd/system/myapp.service
systemctl daemon-reload 2>/dev/null || true
