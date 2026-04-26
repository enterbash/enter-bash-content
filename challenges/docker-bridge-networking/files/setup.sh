#!/bin/bash
# Setup: clean up
sudo docker rm -f webhost checker 2>/dev/null || true
sudo docker network rm appnet 2>/dev/null || true
