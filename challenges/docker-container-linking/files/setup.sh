#!/bin/bash
# Setup: clean up
sudo docker rm -f redis-server redis-client 2>/dev/null || true
