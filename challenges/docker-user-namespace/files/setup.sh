#!/bin/bash
# Setup: create a Dockerfile that runs as root
mkdir -p ~/nonroot

cat > ~/nonroot/app.sh << 'EOF'
#!/bin/sh
echo "Running as: $(whoami) (uid=$(id -u))"
while true; do sleep 60; done
EOF
chmod +x ~/nonroot/app.sh

cat > ~/nonroot/Dockerfile << 'EOF'
FROM alpine:latest
WORKDIR /app
COPY app.sh .
RUN chmod +x app.sh
CMD ["./app.sh"]
EOF

sudo docker rm -f safebox 2>/dev/null || true
