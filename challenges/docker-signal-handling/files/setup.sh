#!/bin/bash
# Setup: create an app with broken signal handling
mkdir -p ~/signalapp

cat > ~/signalapp/app.py << 'PYEOF'
import signal
import sys
import time

def handler(signum, frame):
    print(f"Received signal {signum}, shutting down gracefully...")
    sys.exit(0)

signal.signal(signal.SIGTERM, handler)
signal.signal(signal.SIGINT, handler)

print("App started, PID:", __import__('os').getpid())
while True:
    time.sleep(1)
PYEOF

cat > ~/signalapp/Dockerfile << 'EOF'
FROM python:3-alpine
WORKDIR /app
COPY app.py .
ENTRYPOINT python app.py
EOF

sudo docker build -t signalapp:broken ~/signalapp 2>/dev/null || true
sudo docker rm -f sigtest 2>/dev/null || true
