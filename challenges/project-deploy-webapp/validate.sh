#!/bin/bash

# Verify docker daemon is accessible
if ! docker info > /dev/null 2>&1; then
  echo "FAIL: Docker daemon is not running or not accessible"
  exit 1
fi

# Check docker-compose.yml exists
if [ ! -f ~/webapp/docker-compose.yml ]; then
  echo "FAIL: ~/webapp/docker-compose.yml not found"
  exit 1
fi

# Check Dockerfile exists
if [ ! -f ~/webapp/Dockerfile ]; then
  echo "FAIL: ~/webapp/Dockerfile not found"
  exit 1
fi

# Check containers are running
cd ~/webapp
if ! docker compose ps --format '{{.Service}}' 2>/dev/null | grep -q 'app'; then
  echo "FAIL: app service is not running — run 'docker compose up -d'"
  exit 1
fi

if ! docker compose ps --format '{{.Service}}' 2>/dev/null | grep -q 'nginx'; then
  echo "FAIL: nginx service is not running — run 'docker compose up -d'"
  exit 1
fi

# Check the app responds via nginx on port 8080
RESPONSE=$(curl -sf http://localhost:8080 2>/dev/null || true)
if [ -z "$RESPONSE" ]; then
  echo "FAIL: No response from http://localhost:8080 — check nginx proxy_pass config"
  exit 1
fi

# Check response contains expected JSON
if ! echo "$RESPONSE" | grep -q '"status"'; then
  echo "FAIL: Response does not contain expected JSON — got: $RESPONSE"
  exit 1
fi

if ! echo "$RESPONSE" | grep -q 'Enter Bash'; then
  echo "FAIL: Response does not contain 'Enter Bash' — got: $RESPONSE"
  exit 1
fi

echo "PASS: Web application stack is running correctly"
exit 0
