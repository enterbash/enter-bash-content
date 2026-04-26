#!/bin/bash
# Setup: create some garbage resources
sudo docker rm -f old1 old2 old3 2>/dev/null || true
sudo docker network rm unused-net1 unused-net2 2>/dev/null || true

# Create stopped containers
sudo docker run --name old1 alpine echo "done1" 2>/dev/null || true
sudo docker run --name old2 alpine echo "done2" 2>/dev/null || true
sudo docker run --name old3 alpine echo "done3" 2>/dev/null || true

# Create unused networks
sudo docker network create unused-net1 2>/dev/null || true
sudo docker network create unused-net2 2>/dev/null || true

# Create a dangling image
echo "FROM alpine" | sudo docker build -t temp-dangling:v1 - 2>/dev/null || true
sudo docker rmi temp-dangling:v1 2>/dev/null || true
