#!/bin/bash
# Setup: leave swarm if already in one, clean up
sudo docker service rm web-service 2>/dev/null || true
sudo docker swarm leave --force 2>/dev/null || true
sudo docker network rm app-overlay 2>/dev/null || true
