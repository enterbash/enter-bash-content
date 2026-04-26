#!/bin/bash
set -e

# Check .bashrc has the env vars
if ! grep -q 'APP_HOME=/home/runner/app' /home/runner/.bashrc; then
  echo "FAIL: APP_HOME not set in .bashrc"
  exit 1
fi

if ! grep -q 'APP_PORT=3000' /home/runner/.bashrc; then
  echo "FAIL: APP_PORT not set in .bashrc"
  exit 1
fi

if ! grep -q 'APP_ENV=production' /home/runner/.bashrc; then
  echo "FAIL: APP_ENV not set in .bashrc"
  exit 1
fi

# Check the app was started (running flag exists)
if [ ! -f /home/runner/app/running.flag ]; then
  echo "FAIL: App has not been started — run ~/app/start.sh"
  exit 1
fi

# Check the flag has correct values
if ! grep -q '/home/runner/app:3000:production' /home/runner/app/running.flag; then
  echo "FAIL: App started with wrong environment values"
  exit 1
fi

echo "PASS: Environment variables are correctly configured"
exit 0
