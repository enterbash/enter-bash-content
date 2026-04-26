#!/bin/bash

# Check no old-server references remain
if grep -rq 'old-server.example.com' /home/runner/configs/; then
  echo "FAIL: old-server.example.com still found in config files"
  exit 1
fi

# Check new-server is present
if ! grep -rq 'new-server.example.com' /home/runner/configs/; then
  echo "FAIL: new-server.example.com not found in config files"
  exit 1
fi

# Check port 3306 is replaced with 5432
if grep -rq 'db_port = 3306' /home/runner/configs/; then
  echo "FAIL: Port 3306 still found in config files"
  exit 1
fi

if ! grep -rq '5432' /home/runner/configs/; then
  echo "FAIL: Port 5432 not found in config files"
  exit 1
fi

# Check DEBUG is replaced with INFO in .prod.conf files
if grep -q 'DEBUG' /home/runner/configs/app.prod.conf; then
  echo "FAIL: DEBUG still found in app.prod.conf"
  exit 1
fi

if grep -q 'DEBUG' /home/runner/configs/worker.prod.conf; then
  echo "FAIL: DEBUG still found in worker.prod.conf"
  exit 1
fi

echo "PASS: All config files updated correctly"
exit 0
