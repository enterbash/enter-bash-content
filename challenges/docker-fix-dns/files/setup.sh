#!/bin/bash
# Setup: create container with broken DNS
sudo docker rm -f dnsbox dnsbox-fixed 2>/dev/null || true
sudo docker run -d --name dnsbox --dns 192.0.2.1 alpine sleep infinity 2>/dev/null || true
