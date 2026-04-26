#!/bin/bash
# Setup: create a simple image to save
mkdir -p ~/saveimg
cat > ~/saveimg/Dockerfile << 'EOF'
FROM alpine:latest
RUN echo "save test image" > /info.txt
CMD ["cat", "/info.txt"]
EOF
sudo docker build -t savetest:latest ~/saveimg 2>/dev/null || true
rm -f ~/savetest.tar
sudo docker rmi restored:v1 2>/dev/null || true
