#!/bin/bash
# Setup: create two containers on separate networks
docker network create net-web 2>/dev/null || true
docker network create net-client 2>/dev/null || true

# Simple HTTP server container
docker run -d --name web --network net-web \
  python:3-alpine python -m http.server 8080 2>/dev/null || true

# Client container
docker run -d --name client --network net-client \
  alpine:latest sleep infinity 2>/dev/null || true

# Install curl in client
docker exec client apk add --no-cache curl 2>/dev/null || true
