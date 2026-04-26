#!/bin/bash
# Setup: create a broken docker-compose.yml
mkdir -p ~/project

cat > ~/project/docker-compose.yml << 'EOF'
version: "3"
services:
  web:
    image: ngix:alpine
    ports:
      - 8080:80
  api:
  image: python:3-alpine
    ports:
      - "5000:5000"
    command: python -m http.server 5000
EOF
