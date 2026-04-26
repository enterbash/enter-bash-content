#!/bin/bash
# Setup: build a simple image to tag
mkdir -p ~/tagproject
cat > ~/tagproject/Dockerfile << 'EOF'
FROM alpine:latest
RUN echo "taggable image" > /info.txt
CMD ["cat", "/info.txt"]
EOF
sudo docker build -t tagme:latest ~/tagproject 2>/dev/null || true
