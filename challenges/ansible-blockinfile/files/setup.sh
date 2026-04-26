#!/bin/bash
mkdir -p ~/ansible-project
mkdir -p /tmp/blockinfile-test
cat > /tmp/blockinfile-test/nginx.conf << 'EOF'
# Nginx Configuration
worker_processes auto;

events {
    worker_connections 1024;
}

http {
    include mime.types;
    default_type application/octet-stream;
}
EOF
