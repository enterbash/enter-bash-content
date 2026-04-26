#!/bin/bash
# Setup: create a mystery container
sudo docker rm -f mystery 2>/dev/null || true
sudo docker run -d --name mystery --hostname myhost nginx:alpine 2>/dev/null || true
rm -f ~/report.txt
