#!/bin/bash
# Setup: create a spawner app
mkdir -p ~/spawner

cat > ~/spawner/spawn.sh << 'EOF'
#!/bin/sh
echo "Main process PID: $$"
# Spawn some child processes
for i in 1 2 3; do
  sleep 3600 &
done
echo "Spawned child processes"
# Keep running
while true; do sleep 60; done
EOF

cat > ~/spawner/Dockerfile << 'EOF'
FROM alpine:latest
RUN apk add --no-cache procps
WORKDIR /app
COPY spawn.sh .
RUN chmod +x spawn.sh
CMD ["./spawn.sh"]
EOF

sudo docker rm -f no-init with-init 2>/dev/null || true
