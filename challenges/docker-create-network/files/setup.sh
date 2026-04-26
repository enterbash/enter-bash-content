#!/bin/bash
# Setup: clean up any existing resources
sudo docker rm -f web tester 2>/dev/null || true
sudo docker network rm mynet 2>/dev/null || true
