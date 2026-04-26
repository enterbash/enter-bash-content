#!/bin/bash
set -e

# Check that config.json exists
if [ ! -f /home/runner/app/config.json ]; then
  echo "FAIL: /home/runner/app/config.json does not exist"
  exit 1
fi

# Check that it has the correct content
if ! grep -q '"database"' /home/runner/app/config.json; then
  echo "FAIL: config.json does not contain expected content"
  exit 1
fi

if ! grep -q '"host"' /home/runner/app/config.json; then
  echo "FAIL: config.json is missing expected fields"
  exit 1
fi

echo "PASS: config.json recovered with correct content"
exit 0
