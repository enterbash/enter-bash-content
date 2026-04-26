#!/bin/bash

# Check exports file has an entry
if ! grep -q '/srv/nfs/shared' /etc/exports; then
  echo "FAIL: /etc/exports does not export /srv/nfs/shared"
  exit 1
fi

# Check the export has rw option
if ! grep '/srv/nfs/shared' /etc/exports | grep -q 'rw'; then
  echo "FAIL: NFS export is not configured for read-write"
  exit 1
fi

# Check mount point exists and is mounted
if ! mountpoint -q /mnt/nfs-test 2>/dev/null; then
  echo "FAIL: /mnt/nfs-test is not mounted"
  exit 1
fi

# Check we can read files from the mount
if [ ! -f /mnt/nfs-test/testfile.txt ]; then
  echo "FAIL: Cannot read testfile.txt from NFS mount"
  exit 1
fi

echo "PASS: NFS share is configured and mounted"
exit 0
