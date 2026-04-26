#!/bin/bash
set -e

mkdir -p /home/runner/configs

# Create config files with old values
cat > /home/runner/configs/app.conf <<'EOF'
server_host = old-server.example.com
server_port = 8080
db_host = old-server.example.com
db_port = 3306
log_level = INFO
EOF

cat > /home/runner/configs/app.prod.conf <<'EOF'
server_host = old-server.example.com
server_port = 8080
db_host = old-server.example.com
db_port = 3306
log_level = DEBUG
cache_host = old-server.example.com
EOF

cat > /home/runner/configs/worker.conf <<'EOF'
queue_host = old-server.example.com
db_port = 3306
log_level = INFO
EOF

cat > /home/runner/configs/worker.prod.conf <<'EOF'
queue_host = old-server.example.com
db_port = 3306
log_level = DEBUG
retry_count = 3
EOF
