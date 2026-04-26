#!/bin/bash
# Setup: create data directory with a config file
sudo docker rm -f databox 2>/dev/null || true
mkdir -p ~/data
echo "app_name=myapp" > ~/data/config.txt
echo "version=1.0" >> ~/data/config.txt
