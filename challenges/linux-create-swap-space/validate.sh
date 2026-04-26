#!/bin/bash
set -e

# Check swap file exists
if [ ! -f /swapfile ]; then
  echo "FAIL: /swapfile does not exist"
  exit 1
fi

# Check swap file permissions (should be 600)
PERMS=$(stat -c '%a' /swapfile)
if [ "$PERMS" != "600" ]; then
  echo "FAIL: /swapfile permissions should be 600, got $PERMS"
  exit 1
fi

# Check swap is active
if ! swapon --show | grep -q '/swapfile'; then
  echo "FAIL: /swapfile is not active as swap"
  exit 1
fi

# Check fstab entry
if ! grep -qE '/swapfile\s+.*swap' /etc/fstab; then
  echo "FAIL: /swapfile not found in /etc/fstab"
  exit 1
fi

echo "PASS: Swap space is properly configured"
exit 0
