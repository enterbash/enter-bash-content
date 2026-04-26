#!/bin/bash
# Setup: run a workbox container
sudo docker rm -f workbox 2>/dev/null || true
sudo docker run -d --name workbox alpine sleep infinity 2>/dev/null || true
