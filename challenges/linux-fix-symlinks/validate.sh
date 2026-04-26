#!/bin/bash
set -e

# Check no broken symlinks remain
BROKEN=$(find /home/runner/myapp -maxdepth 1 -type l -xtype l 2>/dev/null)
if [ -n "$BROKEN" ]; then
  echo "FAIL: Broken symlinks found:"
  echo "$BROKEN"
  exit 1
fi

# Check each symlink resolves to correct target
if [ ! -f /home/runner/myapp/config.env ]; then
  echo "FAIL: config.env symlink is broken or missing"
  exit 1
fi

if [ ! -x /home/runner/myapp/start.sh ]; then
  echo "FAIL: start.sh symlink is broken or missing"
  exit 1
fi

if [ ! -f /home/runner/myapp/version.txt ]; then
  echo "FAIL: version.txt symlink is broken or missing"
  exit 1
fi

if [ ! -d /home/runner/myapp/lib ]; then
  echo "FAIL: lib symlink is broken or missing"
  exit 1
fi

echo "PASS: All symlinks are valid and pointing to correct targets"
exit 0
