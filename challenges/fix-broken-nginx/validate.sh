#!/bin/bash
# Validation: check that nginx is running and serving content

# Check nginx is running
if ! pgrep -x nginx > /dev/null 2>&1; then
  echo "FAIL: Nginx is not running"
  exit 1
fi

# Check nginx config is valid
if ! sudo nginx -t > /dev/null 2>&1; then
  echo "FAIL: Nginx configuration is invalid — run 'sudo nginx -t' to see errors"
  exit 1
fi

# Check it serves content on port 80
RESPONSE=$(curl -sf http://localhost 2>/dev/null || true)
if echo "$RESPONSE" | grep -q "Welcome to Enter Bash"; then
  echo "PASS: Nginx is serving the correct page"
  exit 0
else
  echo "FAIL: Nginx is not serving the expected content"
  exit 1
fi
