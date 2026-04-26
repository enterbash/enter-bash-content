#!/bin/bash
set -e

# Check that old log files are removed
OLD_LOGS=$(find /var/log/myapp -name "*.log.old" 2>/dev/null | wc -l)
if [ "$OLD_LOGS" -gt 0 ]; then
  echo "FAIL: Old log files still exist in /var/log/myapp/"
  exit 1
fi

# Check that build cache is cleaned
if [ -d /tmp/build-cache ] && [ "$(du -sm /tmp/build-cache 2>/dev/null | cut -f1)" -gt 5 ]; then
  echo "FAIL: /tmp/build-cache still has significant data"
  exit 1
fi

# Check that old downloads are removed
OLD_DEBS=$(find /home/runner/downloads -name "*.deb" 2>/dev/null | wc -l)
if [ "$OLD_DEBS" -gt 0 ]; then
  echo "FAIL: Old .deb files still in /home/runner/downloads/"
  exit 1
fi

echo "PASS: Disk space has been cleaned up"
exit 0
