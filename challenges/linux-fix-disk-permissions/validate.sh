#!/bin/bash
set -e

# Check mount point exists and is mounted
if ! mountpoint -q /mnt/data 2>/dev/null; then
  echo "FAIL: /mnt/data is not mounted"
  exit 1
fi

# Check ownership
OWNER=$(stat -c '%U' /mnt/data)
if [ "$OWNER" != "runner" ]; then
  echo "FAIL: /mnt/data should be owned by runner, got $OWNER"
  exit 1
fi

# Check permissions allow access
PERMS=$(stat -c '%a' /mnt/data)
if [ "$PERMS" = "700" ] && [ "$OWNER" = "root" ]; then
  echo "FAIL: /mnt/data is still restricted to root"
  exit 1
fi

# Check uploads directory exists
if [ ! -d /mnt/data/uploads ]; then
  echo "FAIL: /mnt/data/uploads/ does not exist"
  exit 1
fi

# Check logs directory exists
if [ ! -d /mnt/data/logs ]; then
  echo "FAIL: /mnt/data/logs/ does not exist"
  exit 1
fi

# Check runner can write
if ! sudo -u runner touch /mnt/data/test-write 2>/dev/null; then
  echo "FAIL: runner user cannot write to /mnt/data"
  exit 1
fi
rm -f /mnt/data/test-write

echo "PASS: Disk mount permissions are correct"
exit 0
