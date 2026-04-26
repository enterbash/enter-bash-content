#!/bin/bash
# Setup: run nginx without port mapping
sudo docker rm -f webserver 2>/dev/null || true
sudo docker run -d --name webserver nginx:alpine 2>/dev/null || true
