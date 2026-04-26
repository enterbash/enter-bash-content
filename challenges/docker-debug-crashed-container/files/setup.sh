#!/bin/bash
# Setup: create an app that crashes without config
mkdir -p ~/crashapp

cat > ~/crashapp/app.sh << 'APPEOF'
#!/bin/sh
if [ ! -f /app/config.json ]; then
  echo "ERROR: /app/config.json not found! Cannot start."
  exit 1
fi
echo "Config loaded. Server running..."
while true; do sleep 60; done
APPEOF

cat > ~/crashapp/Dockerfile << 'EOF'
FROM alpine:latest
WORKDIR /app
COPY app.sh .
RUN chmod +x app.sh
CMD ["./app.sh"]
EOF

sudo docker build -t crashtest:latest ~/crashapp 2>/dev/null || true
sudo docker rm -f webapp 2>/dev/null || true
sudo docker run -d --name webapp crashtest:latest 2>/dev/null || true
