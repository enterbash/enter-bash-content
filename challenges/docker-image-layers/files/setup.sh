#!/bin/bash
# Setup: create a bloated Dockerfile
mkdir -p ~/bloated

cat > ~/bloated/app.py << 'EOF'
print("Hello from optimized app!")
EOF

cat > ~/bloated/requirements.txt << 'EOF'
# no dependencies needed
EOF

cat > ~/bloated/Dockerfile << 'EOF'
FROM python:3-slim
RUN apt-get update
RUN apt-get install -y curl
RUN apt-get install -y wget
RUN apt-get install -y vim
WORKDIR /app
COPY . .
RUN pip install --no-cache-dir -r requirements.txt
CMD ["python", "app.py"]
EOF

sudo docker build -t bloated:latest ~/bloated 2>/dev/null || true
