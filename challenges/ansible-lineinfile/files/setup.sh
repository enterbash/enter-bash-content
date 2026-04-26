#!/bin/bash
mkdir -p ~/ansible-project
mkdir -p /tmp/lineinfile-test
cat > /tmp/lineinfile-test/app.conf << 'EOF'
# Application Config
port=8080
debug=false
log_level=warning
max_workers=4
EOF
