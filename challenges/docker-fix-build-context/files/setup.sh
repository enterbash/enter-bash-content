#!/bin/bash
# Setup: create a project with large unnecessary files
mkdir -p ~/bigproject/data ~/bigproject/node_modules ~/bigproject/.git

# Create some large files
dd if=/dev/zero of=~/bigproject/data/bigfile.bin bs=1M count=5 2>/dev/null
dd if=/dev/zero of=~/bigproject/node_modules/package.bin bs=1M count=5 2>/dev/null
echo "git data" > ~/bigproject/.git/HEAD
echo "error log" > ~/bigproject/app.log
echo "debug log" > ~/bigproject/debug.log

cat > ~/bigproject/app.py << 'EOF'
print("Hello from slim project!")
EOF

cat > ~/bigproject/Dockerfile << 'EOF'
FROM alpine:latest
WORKDIR /app
COPY . .
CMD ["cat", "app.py"]
EOF
