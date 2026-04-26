#!/bin/bash
# Setup: create an app with permission issues
mkdir -p ~/permapp

cat > ~/permapp/app.sh << 'APPEOF'
#!/bin/sh
echo "Starting app as $(whoami) (uid=$(id -u))"
echo "$(date) App started" > /app/data/app.log
if [ $? -ne 0 ]; then
  echo "ERROR: Cannot write to /app/data/app.log"
  exit 1
fi
echo "App running..."
while true; do sleep 60; done
APPEOF

cat > ~/permapp/Dockerfile << 'EOF'
FROM alpine:latest
RUN mkdir -p /app/data
WORKDIR /app
COPY app.sh .
RUN chmod +x app.sh
USER 1000
CMD ["./app.sh"]
EOF

sudo docker build -t permapp:latest ~/permapp 2>/dev/null || true
