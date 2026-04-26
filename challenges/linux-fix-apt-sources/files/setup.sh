#!/bin/bash
set -e

# Back up original sources
cp /etc/apt/sources.list /etc/apt/sources.list.original 2>/dev/null || true

# Break the sources list
cat > /etc/apt/sources.list <<'EOF'
# Broken sources
deb http://nonexistent.invalid/ubuntu noble main
deb http://also-broken.invalid/ubuntu noble universe
EOF

# Add a broken sources.list.d file
echo "deb http://ppa.broken.invalid/ubuntu noble main" > /etc/apt/sources.list.d/broken-ppa.list
