#!/bin/bash

# Check deploy.sh is executable
if [ ! -x /home/runner/app/deploy.sh ]; then
  echo "FAIL: deploy.sh is not executable"
  exit 1
fi

# Check config.txt is readable
if [ ! -r /home/runner/app/config.txt ]; then
  echo "FAIL: config.txt is not readable"
  exit 1
fi

# Check logs dir is writable
if [ ! -w /home/runner/app/logs ]; then
  echo "FAIL: logs/ directory is not writable"
  exit 1
fi

# Check deploy log exists (script was run)
if [ ! -f /home/runner/app/logs/deploy.log ]; then
  echo "FAIL: deploy.log not found — run the deploy script"
  exit 1
fi

echo "PASS: All permissions correct and deploy ran successfully"
exit 0
