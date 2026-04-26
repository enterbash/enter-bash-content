#!/bin/bash

# Check that cpu_hog process is no longer running
if pgrep -f cpu_hog > /dev/null 2>&1; then
  echo "FAIL: cpu_hog process is still running"
  exit 1
fi

echo "PASS: cpu_hog process has been terminated"
exit 0
